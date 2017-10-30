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

    public enum Value {
        case raw([Result])
        case converted(Any)
    }

    let position: Position
    let choice: Int
    let value: Value

    var children: [Result] {
        switch self.value {
        case .raw(let children): return children
        case .converted: return []
        }
    }

    public init(position: Position, choice: Int = -1, value: Value) {
        self.position = position
        self.choice = choice
        self.value = value
    }

    public init(position: Position, choice: Int = -1) {
        self.position = position
        self.choice = choice
        self.value = .raw([])
    }

    public var text: String {
        return self.position.matchedText
    }

    public func converted<T>() -> T? {
        switch self.value {
        case .converted(let value as T):
            return value
        default:
            return nil
        }
    }

    func with(value: Value) -> Result {
        return Result(position: self.position, choice: self.choice, value: value)
    }
}

extension Result: CustomStringConvertible {
    public var description: String {
        return "\(self.position.range)"
    }
}
