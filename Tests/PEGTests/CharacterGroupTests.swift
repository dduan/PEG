import XCTest
@testable import PEG

final class CharacterExtensionTests: XCTestCase {
    func testCharacterIsPriorTo() {
        XCTAssertTrue(Character("a").isImmediatelyPrior(to: "b"))
        XCTAssertTrue(Character("y").isImmediatelyPrior(to: "z"))
        XCTAssertFalse(Character("x").isImmediatelyPrior(to: "z"))
        XCTAssertFalse(Character("b").isImmediatelyPrior(to: "a"))
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

final class CharacterGroupTests: XCTestCase {
    func testInit() {
        let tests: [([ClosedRange<Character>], String)] = [
            ([
                "j"..."n",
             ], "j-n"),

            ([
                "j"..."n",
                "j"..."n",
             ], "j-n"),

            ([
                "j"..."n",
                "k"..."m",
             ], "j-n"),

            ([
                "j"..."n",
                "i"..."o",
             ], "i-o"),

            ([
                "j"..."n",
                "n"..."p",
             ], "j-p"),

            ([
                "j"..."n",
                "o"..."p",
             ], "j-p"),

            ([
                "j"..."n",
                "g"..."l",
             ], "g-n"),

            ([
                "j"..."n",
                "g"..."j",
             ], "g-n"),

            ([
                "j"..."n",
                "g"..."i",
             ], "g-n"),

            ([
                "j"..."n",
                "d"..."f",
             ], "d-fj-n"),

            ([
                "j"..."n",
                "q"..."s",
             ], "j-nq-s"),

            ([
                "j"..."n",
                "p"..."s",
                "o"..."o",
             ], "j-s"),

            ([
                "j"..."n",
                "p"..."s",
                "e"..."h",
             ], "e-hj-np-s"),

            ([
                "j"..."n",
                "e"..."h",
                "i"..."i",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "g"..."l",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "e"..."n",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "e"..."n",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "d"..."o",
             ], "d-o"),

            ([
                "j"..."n",
                "e"..."h",
                "d"..."k",
             ], "d-n"),
        ]

        for (input, expected) in tests {
            XCTAssertEqual(CharacterGroup(input).description, expected, "\(input)")
        }
    }

    func testInsert() {
        let tests: [([ClosedRange<Character>], String)] = [
            ([
                "j"..."n",
             ], "j-n"),

            ([
                "j"..."n",
                "j"..."n",
             ], "j-n"),

            ([
                "j"..."n",
                "k"..."m",
             ], "j-n"),

            ([
                "j"..."n",
                "i"..."o",
             ], "i-o"),

            ([
                "j"..."n",
                "n"..."p",
             ], "j-p"),

            ([
                "j"..."n",
                "o"..."p",
             ], "j-p"),

            ([
                "j"..."n",
                "g"..."l",
             ], "g-n"),

            ([
                "j"..."n",
                "g"..."j",
             ], "g-n"),

            ([
                "j"..."n",
                "g"..."i",
             ], "g-n"),

            ([
                "j"..."n",
                "d"..."f",
             ], "d-fj-n"),

            ([
                "j"..."n",
                "q"..."s",
             ], "j-nq-s"),

            ([
                "j"..."n",
                "p"..."s",
                "o"..."o",
             ], "j-s"),

            ([
                "j"..."n",
                "p"..."s",
                "e"..."h",
             ], "e-hj-np-s"),

            ([
                "j"..."n",
                "e"..."h",
                "i"..."i",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "g"..."l",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "e"..."n",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "e"..."n",
             ], "e-n"),

            ([
                "j"..."n",
                "e"..."h",
                "d"..."o",
             ], "d-o"),

            ([
                "j"..."n",
                "e"..."h",
                "d"..."k",
             ], "d-n"),
        ]

        for (input, expected) in tests {
            let group = CharacterGroup()
            for range in input {
                group.insert(range)
            }

            XCTAssertEqual(group.description, expected, "\(input)")
        }
    }

    func testContains() {
        let tests: [([ClosedRange<Character>], Character)] = [
            ([
                "j"..."n",
             ], "j"),
            ([
                "j"..."n",
             ], "n"),
            ([
                "j"..."n",
             ], "k"),
            ([
                "j"..."j",
             ], "j"),
            ([
                "a"..."a",
                "p"..."s",
             ], "q"),
            ([
                "a"..."a",
                "p"..."s",
             ], "a"),
            ([
                "p"..."s",
                "y"..."z",
             ], "q"),
        ]

        for test in tests {
            XCTAssertTrue(CharacterGroup(test.0).contains(test.1))
        }
    }
}
