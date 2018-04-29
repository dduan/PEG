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
        grammar.convert(kPrimary) { node in
            if node.choice == 1 {
                return node[0].converted(Double.self) !! "Expected Primary choice #2"
            }

            return node[0][1].converted(Double.self) !! "Expected Primary choice #1"
        }

        // MulExpr    <- ('*' / '/') Primary
        grammar.convert(kMulExpr) { node in
            var n: Double = node[1].converted()!
            let op = node[0]
            if op.choice == 1 {
                n = 1 / n
            }
            return n
        }

        // Factor     <- Primary MulExpr*
        grammar.convert(kFactor) { node in
            let n: Double = node[0].converted()!
            return node[1]
                .children
                .reduce(n) { $0 * $1.converted()! }
        }

        // AddExpr    <- ('+' / '-') Factor
        grammar.convert(kAddExpr) { node in
            var n: Double = node.children[1].converted()!
            let op = node.children[0]
            if op.choice == 1 {
                n = -n
            }
            return n
        }

        // Arithmetic <- Factor AddExpr*
        grammar.convert(kArithmetic) { node in
            let n: Double = node.children[0].converted() ?? 0
            return node[1]
                .children
                .reduce(n) { $0 + $1.converted()! }
        }


        let node = try grammar.parse("(96+1)/2-100")

        let nodeValue = node.converted(Double.self)
        XCTAssertNotNil(nodeValue)

        if let value = nodeValue {
            XCTAssertEqual(value , -51.5, accuracy: 0.1)
        }
    }
}
