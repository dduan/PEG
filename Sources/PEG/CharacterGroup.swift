// [a-d] + [c-g] = [a-g]
// [a-d] + [g-g] = [a-d, g-g]
// [a-c] + [d-d] = [a-d]

extension Character {
    func isNextTo(_ other: Character) -> Bool {
        fatalError()
    }
}

extension ClosedRange where Bound == Character {
    func inMergable(_ other: ClosedRange<Character>) -> Bool {
        fatalError()
    }
}

public struct CharacterGroup {
    var ranges = [ClosedRange<Character>]()

    func insert(_ range: ClosedRange<Character>) {
    }

    func contains(_ character: Character) -> Bool {
        fatalError()
    }
}
