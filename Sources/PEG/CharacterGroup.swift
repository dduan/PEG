// [a-d] + [c-g] = [a-g]
// [a-d] + [g-g] = [a-d, g-g]
// [a-c] + [d-d] = [a-d]

extension Character {
    func isPrior(to other: Character) -> Bool {
        if self.unicodeScalars.count != other.unicodeScalars.count {
            return false
        }

        for (u0, u1) in zip(self.unicodeScalars.dropLast(), other.unicodeScalars.dropLast()) {
            if u0 != u1 {
                return false
            }
        }

        return self.unicodeScalars.last!.value + 1 == other.unicodeScalars.last!.value
    }
}

extension ClosedRange where Bound == Character {
    func inMergable(_ other: ClosedRange<Character>) -> Bool {
        return self.overlaps(other) ||
            self.upperBound.isPrior(to: other.lowerBound) ||
            other.upperBound.isPrior(to: self.lowerBound)
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
