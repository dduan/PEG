import XCTest
@testable import PEG

final class ExpressionTests: XCTestCase {
    private func ctx(_ text: String) -> Context {
        return Context(text: text, position: 0)
    }

    let literal = s("aa")

    func testLiteral() {
        XCTAssertEqual(literal.parse(ctx("aa"))?.text, "aa")
        XCTAssertEqual(literal.parse(ctx("aab"))?.text, "aa")
        XCTAssertNil(literal.parse(ctx("aba")))
    }

    let group = c(CharacterGroup(["d"..."g", "p"..."p"]))
    func testGroup() {
        XCTAssertEqual(group.parse(ctx("e"))?.text, "e")
        XCTAssertEqual(group.parse(ctx("pxxxx"))?.text, "p")
        XCTAssertNil(group.parse(ctx("a")))
    }

    func testSequence() {
        let sequence = seq(group, literal, group)
        XCTAssertNotNil(sequence.parse(ctx("daafxxxx")))
        let result = sequence.parse(ctx("daaf"))
        XCTAssertNotNil(result)
        if let sequenceResult = result {
            XCTAssertEqual(sequenceResult.children.count, 3)
            XCTAssertEqual(sequenceResult.children[0].text, "d")
            XCTAssertEqual(sequenceResult.children[1].text, "aa")
            XCTAssertEqual(sequenceResult.children[2].text, "f")
        }
    }
}
