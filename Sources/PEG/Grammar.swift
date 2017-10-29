struct Rule {
    let name: String
    let expression: Expression

    func parse(_ context: Context) -> Result? {
        return self.expression.parse(context)
    }
}

public struct Grammar {
    let rootName: String
    let rules: [String: Rule]

    public init(rootName: String, _ rules: String) {
        self.rootName = rootName
        // TODO: actually compute the rules.
        self.rules = [:]
    }

    public func parse(_ text: String) -> Result? {
        let context = Context(text: text, position: 0)
        return self.rules[self.rootName]?.parse(context)
    }
}

