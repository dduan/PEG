public final class Context {
    public let text: String
    public var cursor: Int
    public var grammar: Grammar

    public init(text: String, position: Int, grammar: Grammar) {
        self.text = text
        self.cursor = position
        self.grammar = grammar
    }
}

extension Context: CustomStringConvertible {
    public var description: String {
        return "\(self.cursor)|\(self.text.dropFirst(self.cursor))"
    }
}
