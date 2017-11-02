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
    func isMergable(with other: ClosedRange<Character>) -> Bool {
        return self.overlaps(other) ||
            self.upperBound.isPrior(to: other.lowerBound) ||
            other.upperBound.isPrior(to: self.lowerBound)
    }
}

public struct CharacterGroup {
    var ranges = [ClosedRange<Character>]()

    public init(_ ranges: [ClosedRange<Character>]) {
        self.ranges.reserveCapacity(ranges.count)
        for range in ranges {
            self.insert(range)
        }
    }

    public init(_ ranges: ClosedRange<Character>...) {
        self.init(ranges)
    }

    public func insert(_ range: ClosedRange<Character>) {
    }

    public func contains(_ character: Character) -> Bool {
        fatalError()
    }
}

extension CharacterGroup: CustomStringConvertible {
    public var description: String {
        return self.ranges
            .map { $0.lowerBound == $0.upperBound ? "\($0.upperBound)" : "\($0.lowerBound)-\($0.upperBound)" }
            .joined(separator: "")
    }
}
