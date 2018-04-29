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
        primaryExpr.convert = { node in
            if node.choice == 1 {
                return node[0].converted(Double.self)!
            }
            return node[0][1].converted(Double.self)!
        }

        // MulExpr    <- ('*' / '/') Primary
        mulExpr.convert = { node in
            var n: Double = node.children[1].converted()!
            let op = node.children[0]
            if op.choice == 1 {
                n = 1 / n
            }
            return n
        }

        // Factor     <- Primary MulExpr*
        factorExpr.convert = { node in
            let n: Double = node.children[0].converted()!
            return node.children[1]
                .children
                .reduce(n) { $0 * $1.converted()! }
        }

        // AddExpr    <- ('+' / '-') Factor
        addExpr.convert = { node in
            var n: Double = node.children[1].converted()!
            let op = node.children[0]
            if op.choice == 1 {
                n = -n
            }
            return n
        }

        // Arithmetic <- Factor AddExpr*
        arithmeticExpr.convert = { node in
            let n: Double = node.children[0].converted() ?? 0
            return node.children[1]
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

        let node = try? grammar.parse("(96+1)/2-100")
        XCTAssertNotNil(node)

        let nodeValue = node?.converted(Double.self)
        XCTAssertNotNil(nodeValue)

        if let value = nodeValue {
            XCTAssertEqual(value , -51.5, accuracy: 0.1)
        }
    }
}
