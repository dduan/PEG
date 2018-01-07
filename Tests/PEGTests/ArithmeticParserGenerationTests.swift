import XCTest
import PEG

final class ArithmeticParserGenerationTests: XCTestCase {
    func testParserGeneration() throws {
        let input = """
            Arithmetic <- Factor AddExpr*
            AddExpr    <- ('+' / '-') Factor
            Factor     <- Primary MulExpr*
            MulExpr    <- ('*' / '/') Primary
            Primary    <- '(' Arithmetic ')' / Number
            Number     <- [0-9]+
        """

        let kArithmetic = "Arithmetic"
        let kAddExpr    = "AddExpr"
        let kFactor     = "Factor"
        let kMulExpr    = "MulExpr"
        let kPrimary    = "Primary"
        let kNumber     = "Number"

        let grammar = try Grammar(rootName: kArithmetic, input)

        // Number     <- [0-9]+
        grammar.convert(kNumber) { Double($0.text)! }

        // Primary    <- '(' Arithmetic ')' / Number
        grammar.convert(kPrimary) { result in
            if result.choice == 1 {
                return result.converted(Double.self) !! "Expected Primary choice #2"
            }

            return result[1].converted(Double.self) !! "Expected Primary choice #1"
        }

        // MulExpr    <- ('*' / '/') Primary
        grammar.convert(kMulExpr) { result in
            var n: Double = result[1].converted()!
            let op = result[0]
            if op.choice == 1 {
                n = 1 / n
            }
            return n
        }

        // Factor     <- Primary MulExpr*
        grammar.convert(kFactor) { result in
            let n: Double = result[0].converted()!
            return result[1]
                .children
                .reduce(n) { $0 * $1.converted()! }
        }

        // AddExpr    <- ('+' / '-') Factor
        grammar.convert(kAddExpr) { result in
            var n: Double = result.children[1].converted()!
            let op = result.children[0]
            if op.choice == 1 {
                n = -n
            }
            return n
        }

        // Arithmetic <- Factor AddExpr*
        grammar.convert(kArithmetic) { result in
            let n: Double = result.children[0].converted() ?? 0
            return result[1]
                .children
                .reduce(n) { $0 + $1.converted()! }
        }


        let result = try grammar.parse("(96+1)/2-100")

        let resultValue = result.converted(Double.self)
        XCTAssertNotNil(resultValue)

        if let value = resultValue {
            XCTAssertEqual(value , -51.5, accuracy: 0.1)
        }
    }
}
