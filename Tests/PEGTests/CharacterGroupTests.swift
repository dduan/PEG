import XCTest
@testable import PEG

final class CharacterExtensionTests: XCTestCase {
    func testCharacterIsPriorTo() {
        XCTAssertTrue(Character("a").isPrior(to: "b"))
        XCTAssertTrue(Character("y").isPrior(to: "z"))
        XCTAssertFalse(Character("x").isPrior(to: "z"))
        XCTAssertFalse(Character("b").isPrior(to: "a"))
    }

    static var allTests = [
        ("testCharacterIsPriorTo", testCharacterIsPriorTo),
    ]
}

final class ClosedRangeCharacterExtensionTests: XCTestCase {
    func testClosedRangeCharacterIsMergableWith() {
        XCTAssertTrue((Character("a")...Character("c")).isMergable(with: (Character("d")...Character("f"))))
        XCTAssertTrue((Character("a")...Character("d")).isMergable(with: (Character("d")...Character("f"))))
        XCTAssertTrue((Character("a")...Character("e")).isMergable(with: (Character("d")...Character("f"))))
        XCTAssertTrue((Character("a")...Character("f")).isMergable(with: (Character("d")...Character("f"))))
        XCTAssertTrue((Character("a")...Character("g")).isMergable(with: (Character("d")...Character("f"))))

        XCTAssertTrue((Character("a")...Character("g")).isMergable(with: (Character("a")...Character("g"))))

        XCTAssertTrue((Character("d")...Character("f")).isMergable(with: (Character("a")...Character("c"))))
        XCTAssertTrue((Character("d")...Character("f")).isMergable(with: (Character("a")...Character("d"))))
        XCTAssertTrue((Character("d")...Character("f")).isMergable(with: (Character("a")...Character("e"))))
        XCTAssertTrue((Character("d")...Character("f")).isMergable(with: (Character("a")...Character("f"))))
        XCTAssertTrue((Character("d")...Character("f")).isMergable(with: (Character("a")...Character("g"))))
    }

    static var allTests = [
        ("testClosedRangeCharacterIsMergableWith", testClosedRangeCharacterIsMergableWith),
    ]
}
