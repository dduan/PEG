public struct Result {
    public final class Position {
        let text: String
        let range: Range<Int>

        init(_ text: String, _ start: Int, _ end: Int) {
            self.text = text
            self.range = start..<end
        }

        public var matchedText: String {
            return String(
                self.text
                    .dropFirst(self.range.lowerBound)
                    .prefix(self.range.upperBound - self.range.lowerBound)
            )
        }
    }

    let position: Position
    let choice: Int
    let children: [Result]

    public init(position: Position, choice: Int = -1, children: [Result] = []) {
        self.position = position
        self.choice = choice
        self.children = children
    }

    public var text: String {
        return self.position.matchedText
    }
}

extension Result: CustomStringConvertible {
    public var description: String {
        return "\(self.position.range)"
    }
}
