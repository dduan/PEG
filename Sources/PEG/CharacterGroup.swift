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

public final class CharacterGroup {
    var ranges = [ClosedRange<Character>]()

    public required init(_ ranges: [ClosedRange<Character>]) {
        self.ranges.reserveCapacity(ranges.count)
        for range in ranges {
            self.insert(range)
        }
    }

    public convenience init(_ ranges: ClosedRange<Character>...) {
        self.init(ranges)
    }

    public func insert(_ range: ClosedRange<Character>) {
        if self.ranges.isEmpty {
            self.ranges.append(range)
            return
        }

        var insertPosition = self.find(for: range, 0, self.ranges.count)
        var cursor = insertPosition
        var lowerBound = range.lowerBound
        var upperBound = range.upperBound

        let previousIndex = insertPosition - 1
        if insertPosition > 0 && range.isMergable(with: self.ranges[previousIndex]) {
            lowerBound = self.ranges[previousIndex].lowerBound
            upperBound = max(self.ranges[previousIndex].upperBound, range.upperBound)
            insertPosition -= 1
        }

        while cursor < self.ranges.count && range.isMergable(with: self.ranges[cursor]) {
            upperBound = max(self.ranges[cursor].upperBound, range.upperBound)
            cursor += 1
        }

        self.ranges.replaceSubrange(insertPosition..<cursor, with: [lowerBound...upperBound])
    }

    public func contains(_ character: Character) -> Bool {
        fatalError()
    }

    private func find(for range: ClosedRange<Character>, _ start: Int, _ end: Int) -> Int {
        if start == end {
            return start
        }

        let middle = start + (end - start) / 2

        if range.lowerBound <= self.ranges[middle].lowerBound {
            return self.find(for: range, start, middle)
        } else {
            return self.find(for: range, middle + 1, end)
        }
    }
}

extension CharacterGroup: CustomStringConvertible {
    public var description: String {
        return self.ranges
            .map { $0.lowerBound == $0.upperBound ? "\($0.upperBound)" : "\($0.lowerBound)-\($0.upperBound)" }
            .joined(separator: "")
    }
}
