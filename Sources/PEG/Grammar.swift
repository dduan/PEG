public enum ParserGenerationError: Error {
    case tmp_genartionError
    case tmp_parseError
    case unknownRuleReference(String)
    case unknownRoot(String)
}

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

    public init(rootName: String, _ rules: String) throws {
        self.rootName = rootName
        let peg = Grammar(rootName: "Grammar", bootstrap())
        // TODO: properly implement parser generation error
        guard let rules = try peg.parse(rules).converted([Rule].self) else {
            throw ParserGenerationError.tmp_genartionError
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

    public func parse(_ text: String) throws -> Result {
        let context = Context(text: text, position: 0, grammar: self)
        guard let rootRule = self.rules[self.rootName] else {
            throw ParserGenerationError.unknownRoot(self.rootName)
        }

        return try rootRule.parse(context)
    }

    func parse(ruleName: String, context: Context) throws -> Result {
        guard let rule = self.rules[ruleName] else {
            throw ParserGenerationError.unknownRuleReference(ruleName)
        }

        return try rule.parse(context)
    }
}

