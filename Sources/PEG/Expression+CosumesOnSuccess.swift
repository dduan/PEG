extension Expression {
    func alwaysConsumesOnSuccess(within grammar: Grammar) -> Bool {
        switch self {
        case .literal(let s, _):
            return !s.isEmpty

        case .characterGroup:
            return true

        case .sequence(let expressions, _):
            for expression in expressions {
                if expression.alwaysConsumesOnSuccess(within: grammar) {
                    return true
                }
            }

            return false

        case .oneOf(let expressions, _):
            for expression in expressions {
                if !expression.alwaysConsumesOnSuccess(within: grammar) {
                    return false
                }
            }

            return true

        case .repeat(.oneOrMore, let expression, _):
            return expression.alwaysConsumesOnSuccess(within: grammar)

        case .repeat(.zeroOrMore, _, _):
            return false

        case .peek, .optional:
            return false

        case .rule(let name, _):
            return grammar
                .expression(forRuleWithName: name)?
                .alwaysConsumesOnSuccess(within: grammar)
                ?? false
        }
    }
}
