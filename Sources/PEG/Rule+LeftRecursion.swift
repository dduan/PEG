extension Rule {
    // assumes all rule references are defined
    func checkForLeftRecursion(within grammar: Grammar) throws {
        var encounteredRules = [self.name]

        func validate(_ expression: Expression) throws {
            switch expression {
            case .rule(let name, _):
                if encounteredRules.contains(name) {
                    encounteredRules.append(name)
                    throw GrammarValidationError.infiniteRecursion(encounteredRules)
                }

                guard let ruleExpression = grammar.expression(forRuleWithName: name) else {
                    // TODO: validate for non-existing rules
                    fatalError("Internal error: found non-existent rules validating for left recursion")
                }

                encounteredRules.append(name)
                try validate(ruleExpression)
                encounteredRules.removeLast()

            case .sequence(let subExpressions, _):
                for subExpression in subExpressions {
                    try validate(subExpression)

                    if subExpression.alwaysConsumesOnSuccess(within: grammar) {
                        return
                    }
                }

            case .oneOf(let subExpressions, _):
                for subExpression in subExpressions {
                    try validate(subExpression)
                }

            case .optional(let expression, _):
                try validate(expression)

            case .repeat(_, let expression, _):
                try validate(expression)

            default:
                return
            }
        }

        try validate(self.expression)
    }
}

