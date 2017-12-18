struct Rule {
    let name: String
    let expression: Expression

    public init(_ name: String, expression: Expression) {
        self.name = name
        self.expression = expression
    }

    func parse(_ context: Context) -> Result? {
        return self.expression.parse(context)
    }
}

public final class Grammar {
    let rootName: String
    let rules: [String: Rule]

    func rule(byName name: String) -> Rule? {
        return self.rules[name]
    }

    public init(rootName: String, _ ruleExpressions: [(String, Expression)]) {
        self.rootName = rootName
        let rules = ruleExpressions.map(Rule.init)
        self.rules = [String: Rule](uniqueKeysWithValues: rules.map { ($0.name, $0) })
    }

    public init(rootName: String, _ rules: String) {
        self.rootName = rootName
        // TODO: actually compute the rules.
        self.rules = [:]
    }

    public func parse(_ text: String) -> Result? {
        let context = Context(text: text, position: 0, grammar: self)
        return self.rules[self.rootName]?.parse(context)
    }
}

