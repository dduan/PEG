@testable import PEG
import XCTest

final class LeftRecursionTests: XCTestCase {
    func assureInfiniteRecursion(_ name: String, _ definition: String, file: StaticString = #file, line: UInt = #line)
    {
        XCTAssertThrowsError(try Grammar(rootName: name, definition), file: file, line: line) { error in
            guard case GrammarValidationError.infiniteRecursion = error else {
                XCTFail()
                return
            }
        }
    }

    func assureNoInfiniteRecursion(_ name: String, _ definition: String, file: StaticString = #file, line: UInt = #line)
    {
        XCTAssertNoThrow(try Grammar(rootName: "start", definition))
    }

    func testDirectLeftRecursion() {
        assureInfiniteRecursion("start", "start <- start")
    }

    func testIndirectLeftRecursion() {
        let test =
            """
            start <- stop
            stop <- start
            """

        assureInfiniteRecursion("start", test)
    }

    func testLeftRecursionInEmptySequence() {
        assureInfiniteRecursion("start", "start <- '' '' '' start")
    }

    func testLeftRecursionInNonEmptySequence() {
        let tests = [
            "start <- 'a' '' '' start",
            "start <- '' 'a' '' start",
            "start <- '' '' 'a' start",
        ]

        for test in tests {
            assureNoInfiniteRecursion("start", test)
        }
    }

    func testLeftRecursionInSequenceAndWrappedInOptional() {
        assureInfiniteRecursion("start", "start <- '' start?")
        assureNoInfiniteRecursion("start", "start <- 'a' start?")
    }

    func testLeftRecursionInSequenceAndWrappedInZeroOrMore() {
        assureInfiniteRecursion("start", "start <- '' start*")
        assureNoInfiniteRecursion("start", "start <- 'a' start*")
    }

    func testLeftRecursionInSequenceAndWrappedInOneOrMore() {
        assureInfiniteRecursion("start", "start <- '' start+")
        assureNoInfiniteRecursion("start", "start <- 'a' start+")
    }

    func testLeftRecursionInSequenceWithOneOf() {
        assureInfiniteRecursion("start", "start <- ('' / 'a' / 'b') start")
        assureInfiniteRecursion("start", "start <- ('a' / '' / 'b') start")
        assureInfiniteRecursion("start", "start <- ('a' / 'b' / '') start")
        assureNoInfiniteRecursion("start", "start <- ('a' / 'b' / 'c') start")
    }

    func testLeftRecursionInSequenceWithPredicate() {
        assureInfiniteRecursion("start", "start <- &'' start")
        assureInfiniteRecursion("start", "start <- &'a' start")

        assureInfiniteRecursion("start", "start <- !'' start")
        assureInfiniteRecursion("start", "start <- !'a' start")
    }

    func testLeftRecursionInSequenceWithOptional() {
        assureInfiniteRecursion("start", "start <- ''? start")
        assureInfiniteRecursion("start", "start <- 'a'? start")
    }

    func testLeftRecursionInSequenceWithZeroOrMore() {
        assureInfiniteRecursion("start", "start <- ''* start")
        assureInfiniteRecursion("start", "start <- 'a'* start")
    }

    func testLeftRecursionInSequenceWithOneOrMore() {
        assureInfiniteRecursion("start", "start <- ''+ start")
        assureNoInfiniteRecursion("start", "start <- 'a'+ start")
    }
}
