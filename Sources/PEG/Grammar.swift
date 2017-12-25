public final class Grammar {
    let rootName: String
    private let rules: [String: Rule]

    // TODO: Determine if this is worth keeping as a public interface
    public static let _peg: Grammar = Grammar(rootName: "Grammar", bootstrap())

    public init(rootName: String, _ ruleExpressions: [(String, Expression)]) {
        self.rootName = rootName
        let rules = ruleExpressions.map(Rule.init)
        self.rules = [String: Rule](uniqueKeysWithValues: rules.map { ($0.name, $0) })
    }

    public init?(rootName: String, _ rules: String) {
        self.rootName = rootName
        let peg = Grammar(rootName: "Grammar", bootstrap())
        guard let rules = peg.parse(rules)?.converted([Rule].self) else {
            return nil
        }
        self.rules = [String: Rule](uniqueKeysWithValues: rules.map { ($0.name, $0) })
    }

    init(rootName: String, _ rules: [Rule]) {
        self.rootName = rootName
        self.rules = [String: Rule](uniqueKeysWithValues: rules.map { ($0.name, $0) })
    }

    public func convert(_ ruleName: String, with convert: @escaping (Result) -> Any) {
        self.rules[ruleName]?.expression.convert = convert
    }

    public func parse(_ text: String) -> Result? {
        let context = Context(text: text, position: 0, grammar: self)
        return self.rules[self.rootName]?.parse(context)
    }

    func parse(ruleName: String, context: Context) -> Result? {
        return self.rules[ruleName]?.parse(context)
    }
}

