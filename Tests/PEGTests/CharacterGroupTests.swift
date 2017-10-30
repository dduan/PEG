import XCTest
@testable import PEG

class PEGTests: XCTestCase {
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
