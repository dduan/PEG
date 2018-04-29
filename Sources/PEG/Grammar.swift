public enum ParserGenerationError: Error {
    case generationFailed
    case ruleParsingFailed(ParsingError)
    case unknownRuleReference(String, Context)
    case unknownRoot(String)
}

public enum GrammarValidationError: Error {
    case infiniteRecursion([String])
}

public final class Grammar {
    let rootName: String
    private let rules: [String: Rule]

    // TODO: Determine if this is worth keeping as a public interface
    public static let _peg: Grammar = Grammar(rootName: "Grammar", bootstrap())

    public init(rootName: String, _ rules: String) throws {
        self.rootName = rootName
        let peg = Grammar(rootName: "Grammar", bootstrap())
        do {
            let node = try peg.parse(rules)
            guard let rules = node.converted([Rule].self) else {
                throw ParserGenerationError.generationFailed
            }

            self.rules = [String: Rule](uniqueKeysWithValues: rules.map { ($0.name, $0) })
            try self.validate()
        } catch let error as ParsingError {
            throw ParserGenerationError.ruleParsingFailed(error)
        }
    }

    init(rootName: String, _ ruleExpressions: [(String, Expression)]) {
        self.rootName = rootName
        let rules = ruleExpressions.map(Rule.init)
        self.rules = [String: Rule](uniqueKeysWithValues: rules.map { ($0.name, $0) })
    }

    init(rootName: String, _ rules: [Rule]) {
        self.rootName = rootName
        self.rules = [String: Rule](uniqueKeysWithValues: rules.map { ($0.name, $0) })
    }

    public func convert(_ ruleName: String, with convert: @escaping (Node) -> Any) {
        self.rules[ruleName]?.expression.convert = convert
    }

    public func parse(_ text: String) throws -> Node {
        let context = Context(text: text, position: 0, grammar: self, trace: [])
        guard let rootRule = self.rules[self.rootName] else {
            throw ParserGenerationError.unknownRoot(self.rootName)
        }

        return try rootRule.parse(context)
    }

    func expression(forRuleWithName name: String) -> Expression? {
        return self.rules[name]?.expression
    }

    func parse(ruleName: String, context: Context) throws -> Node {
        guard let rule = self.rules[ruleName] else {
            throw ParserGenerationError.unknownRuleReference(ruleName, context)
        }

        return try rule.parse(context)
    }

    // throws: ParserValidationError
    private func validate() throws {
        try self.checkForLeftRecursion()
    }

    private func checkForLeftRecursion() throws {
        for rule in self.rules.values {
            try rule.checkForLeftRecursion(within: self)
        }
    }
}

