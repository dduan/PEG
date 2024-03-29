public struct Node {
    public final class Position {
        let text: String
        let range: Range<Int>

        init(_ text: String, _ start: Int, _ end: Int) {
            self.text = text
            self.range = start..<end
        }

        init(_ text: String, _ range: Range<Int>) {
            self.text = text
            self.range = range
        }

        var matchedText: String {
            return String(
                self.text
                    .dropFirst(self.range.lowerBound)
                    .prefix(self.range.upperBound - self.range.lowerBound)
            )
        }

        var firstMatchedCharacter: Character? {
            return self.text.dropFirst(self.range.lowerBound).first
        }

        func copy() -> Position {
            return Position(self.text, self.range)
        }
    }

    public enum Value {
        case raw([Node])
        case converted(Any)
    }

    public let choice: Int
    public let position: Position
    public let value: Value

    public var children: [Node] {
        switch self.value {
        case .raw(let children): return children
        case .converted: return []
        }
    }

    public subscript(index: Int) -> Node {
        get {
            return self.children[index]
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

    public var firstCharacter: Character? {
        return self.position.firstMatchedCharacter
    }

    public func converted<T>() -> T? {
        switch self.value {
        case .converted(let value as T):
            return value
        default:
            return nil
        }
    }

    public func converted<T>(_ type: T.Type) -> T? {
        switch self.value {
        case .converted(let value as T):
            return value
        default:
            return nil
        }
    }

    func with(value: Value) -> Node {
        return Node(position: self.position, choice: self.choice, value: value)
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        if self.children.isEmpty {
            if case .converted(let customValue) = self.value {
                return "\(self.choice)|\(customValue)"
            }
            return "\(self.choice)|\(self.text)"
        }
        return "\(self.choice)|\(self.children.count)|\(self.position.range)"
    }
}
