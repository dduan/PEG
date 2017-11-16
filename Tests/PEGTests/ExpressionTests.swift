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
        XCTAssertNotNil(group.parse(Context(text: "aadaap", position: 2)))
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

    func testOneOf() {
        let oneOfExpr = of(group, literal)

        XCTAssertNil(oneOfExpr.parse(ctx("xxxx")))

        let firstChoiceMatch = oneOfExpr.parse(ctx("p"))
        let secondChoiceMatch = oneOfExpr.parse(ctx("aa"))

        XCTAssertNotNil(firstChoiceMatch)
        XCTAssertNotNil(secondChoiceMatch)
        XCTAssertEqual(firstChoiceMatch?.choice, 0)
        XCTAssertEqual(secondChoiceMatch?.choice, 1)
    }

    func testZeroOrMore() {
        let sequence = seq(group, literal, group)
        let repeatExpr0 = zero(sequence)
        XCTAssertNotNil(repeatExpr0.parse(ctx("xxxxxx")))
        let repeatExpr0Result = repeatExpr0.parse(ctx("daafxxxx"))
        XCTAssertNotNil(repeatExpr0Result)
        XCTAssertEqual(repeatExpr0Result?.text, "daaf")
        XCTAssertEqual(repeatExpr0Result?.children[0].text, "daaf")

    }

    func testOneOrMore() {
        let oneOfExpr = of(group, literal)
        let repeatExpr1 = one(oneOfExpr)
        XCTAssertNil(repeatExpr1.parse(ctx("xxxxxx")))

        let result = repeatExpr1.parse(ctx("aadaap"))
        XCTAssertNotNil(result)

        guard let oneOrMoreResult = result else { return }
        XCTAssertEqual(oneOrMoreResult.children.count, 4)
        XCTAssertEqual(oneOrMoreResult.children[0].text, "aa")
        XCTAssertEqual(oneOrMoreResult.children[0].choice, 1)
        XCTAssertEqual(oneOrMoreResult.children[1].text, "d")
        XCTAssertEqual(oneOrMoreResult.children[1].choice, 0)
        XCTAssertEqual(oneOrMoreResult.children[2].text, "aa")
        XCTAssertEqual(oneOrMoreResult.children[2].choice, 1)
        XCTAssertEqual(oneOrMoreResult.children[3].text, "p")
        XCTAssertEqual(oneOrMoreResult.children[3].choice, 0)
    }

    func testPeekLookAhead() {
        let sequence = seq(group, literal, group)
        let aheadExpr = ahead(sequence)
        XCTAssertNotNil(aheadExpr.parse(ctx("daagxxxxx")))
        XCTAssertEqual(aheadExpr.parse(ctx("daagxxxxx"))?.text.isEmpty, true)
        XCTAssertNil(aheadExpr.parse(ctx("xdaagxxxxx")))
    }

    func testPeekNot() {
        let sequence = seq(group, literal, group)
        let notExpr = not(sequence)
        XCTAssertNil(notExpr.parse(ctx("daagxxxxx")))
        XCTAssertNotNil(notExpr.parse(ctx("xdaagxxxxx")))
        XCTAssertEqual(notExpr.parse(ctx("xdaagxxxxx"))?.text.isEmpty, true)
    }
}
