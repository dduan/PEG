public final class Context {
    public let text: String
    public var cursor: Int
    public var grammar: Grammar
    public var trace: [Expression]

    public init(text: String, position: Int, grammar: Grammar, trace: [Expression]) {
        self.text = text
        self.cursor = position
        self.grammar = grammar
        self.trace = trace
    }

    func copy() -> Context {
        return Context(text: self.text, position: self.cursor, grammar: self.grammar, trace: self.trace)
    }
}

extension Context: CustomStringConvertible {
    public var description: String {
        return "\(self.cursor)|\(self.text.dropFirst(self.cursor))|\(self.trace)"
    }
}
