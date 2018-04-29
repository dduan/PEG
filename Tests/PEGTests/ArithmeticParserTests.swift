import XCTest
@testable import PEG

final class ArithmeticParserTests: XCTestCase {
    func testParser() {
        let kArithmetic = "Arithmetic"
        let kAddExpr    = "AddExpr"
        let kFactor     = "Factor"
        let kMulExpr    = "MulExpr"
        let kPrimary    = "Primary"
        let kNumber     = "Number"

        let numberExpr = one(c("0"..."9"))
        let primaryExpr = of(
            seq(
                s("("),
                ref(kArithmetic),
                s(")")),
            ref(kNumber))
        let mulExpr = seq(
            of(
                s("*"),
                s("/")),
            ref(kPrimary))
        let factorExpr = seq(
            ref(kPrimary),
            maybe(
                ref(kMulExpr)))
        let addExpr = seq(
            of(
                s("+"),
                s("-")),
            ref(kFactor))
        let arithmeticExpr = seq(
            ref(kFactor),
            maybe(
                ref(kAddExpr)))

        // Number     <- [0-9]+
        numberExpr.convert  = { Double($0.text)! }

        // Primary    <- '(' Arithmetic ')' / Number
        primaryExpr.convert = { result in
            if result.choice == 1 {
                return result[0].converted(Double.self)!
            }
            return result[0][1].converted(Double.self)!
        }

        // MulExpr    <- ('*' / '/') Primary
        mulExpr.convert = { result in
            var n: Double = result.children[1].converted()!
            let op = result.children[0]
            if op.choice == 1 {
                n = 1 / n
            }
            return n
        }

        // Factor     <- Primary MulExpr*
        factorExpr.convert = { result in
            let n: Double = result.children[0].converted()!
            return result.children[1]
                .children
                .reduce(n) { $0 * $1.converted()! }
        }

        // AddExpr    <- ('+' / '-') Factor
        addExpr.convert = { result in
            var n: Double = result.children[1].converted()!
            let op = result.children[0]
            if op.choice == 1 {
                n = -n
            }
            return n
        }

        // Arithmetic <- Factor AddExpr*
        arithmeticExpr.convert = { result in
            let n: Double = result.children[0].converted() ?? 0
            return result.children[1]
                .children
                .reduce(n) { $0 + $1.converted()! }
        }

        let grammar = Grammar(
            rootName: kArithmetic,
            [
                (kArithmetic, arithmeticExpr),
                (kAddExpr, addExpr),
                (kFactor, factorExpr),
                (kMulExpr, mulExpr),
                (kPrimary, primaryExpr),
                (kNumber, numberExpr),
            ]
        )

        let result = try? grammar.parse("(96+1)/2-100")
        XCTAssertNotNil(result)

        let resultValue = result?.converted(Double.self)
        XCTAssertNotNil(resultValue)

        if let value = resultValue {
            XCTAssertEqual(value , -51.5, accuracy: 0.1)
        }
    }
}
