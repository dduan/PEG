import XCTest
@testable import PEG

final class ExpressionTests: XCTestCase {
    private func ctx(_ text: String, _ position: Int = 0) throws -> Context {
        let grammar = try Grammar(rootName: "", "A <- 'a'")
        return Context(text: text, position: position, grammar: grammar, trace: [])
    }

    let literal = s("aa")

    func testLiteral() throws {
        XCTAssertEqual(try literal.parse(ctx("aa")).text, "aa")
        XCTAssertEqual(try literal.parse(ctx("aab")).text, "aa")
        XCTAssertThrowsError(try literal.parse(ctx("aba")))
    }

    let group = c(CharacterGroup(["d"..."g", "p"..."p"]))
    func testGroup() throws {
        XCTAssertEqual(try group.parse(ctx("e")).text, "e")
        XCTAssertEqual(try group.parse(ctx("pxxxx")).text, "p")
        XCTAssertThrowsError(try group.parse(ctx("a")))
        XCTAssertNoThrow(try group.parse(ctx("aadaap", 2)))
    }

    func testSequence() throws {
        let sequence = seq(group, literal, group)
        XCTAssertNoThrow(try sequence.parse(ctx("daafxxxx")))
        let result = try sequence.parse(ctx("daaf"))
        XCTAssertEqual(result.children.count, 3)
        XCTAssertEqual(result.children[0].text, "d")
        XCTAssertEqual(result.children[1].text, "aa")
        XCTAssertEqual(result.children[2].text, "f")
    }

    func testOneOf() throws {
        let oneOfExpr = of(group, literal)

        XCTAssertThrowsError(try oneOfExpr.parse(ctx("xxxx")))

        let firstChoiceMatch = try oneOfExpr.parse(ctx("p"))
        let secondChoiceMatch = try oneOfExpr.parse(ctx("aa"))

        XCTAssertEqual(firstChoiceMatch.choice, 0)
        XCTAssertEqual(secondChoiceMatch.choice, 1)
    }

    func testZeroOrMore() throws {
        let sequence = seq(group, literal, group)
        let repeatExpr0 = zero(sequence)
        XCTAssertNoThrow(try repeatExpr0.parse(ctx("xxxxxx")))
        let repeatExpr0Result = try repeatExpr0.parse(ctx("daafxxxx"))
        XCTAssertEqual(repeatExpr0Result.text, "daaf")
        XCTAssertEqual(repeatExpr0Result.children[0].text, "daaf")

    }

    func testOneOrMore() throws {
        let oneOfExpr = of(group, literal)
        let repeatExpr1 = one(oneOfExpr)
        XCTAssertThrowsError(try repeatExpr1.parse(ctx("xxxxxx")))

        let result = try repeatExpr1.parse(ctx("aadaap"))

        XCTAssertEqual(result.children.count, 4)
        XCTAssertEqual(result.children[0].text, "aa")
        XCTAssertEqual(result.children[0].choice, 1)
        XCTAssertEqual(result.children[1].text, "d")
        XCTAssertEqual(result.children[1].choice, 0)
        XCTAssertEqual(result.children[2].text, "aa")
        XCTAssertEqual(result.children[2].choice, 1)
        XCTAssertEqual(result.children[3].text, "p")
        XCTAssertEqual(result.children[3].choice, 0)
    }

    func testPeekLookAhead() throws {
        let sequence = seq(group, literal, group)
        let aheadExpr = ahead(sequence)
        XCTAssertNoThrow(try aheadExpr.parse(ctx("daagxxxxx")))
        XCTAssertEqual(try aheadExpr.parse(ctx("daagxxxxx")).text.isEmpty, true)
        XCTAssertThrowsError(try aheadExpr.parse(ctx("xdaagxxxxx")))
    }

    func testPeekNot() throws {
        let sequence = seq(group, literal, group)
        let notExpr = not(sequence)
        XCTAssertThrowsError(try notExpr.parse(ctx("daagxxxxx")))
        XCTAssertNoThrow(try notExpr.parse(ctx("xdaagxxxxx")))
        XCTAssertEqual(try notExpr.parse(ctx("xdaagxxxxx")).text.isEmpty, true)
    }

    func testOptional() throws {
        let maybeExpr = maybe(literal)

        let maybeNoResult = try maybeExpr.parse(ctx("xxxx"))
        XCTAssertEqual(maybeNoResult.text.isEmpty, true)

        let maybeYesResult = try maybeExpr.parse(ctx("aaxx"))
        XCTAssertEqual(maybeYesResult.text, "aa")
    }
}
