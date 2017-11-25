extension Expression {
    public func parse(_ context: Context) -> Result? {
        guard let rawResult = self.parse(raw: context) else {
            return nil
        }

        guard let convert = self.convert else {
            return rawResult
        }

        return rawResult.with(value: .converted(convert(rawResult)))
    }

    private func parse(raw context: Context) -> Result? {
        switch self {
        case .literal(let literal, _):
            return self.parseLiteral(with: literal, context: context)
        case .characterGroup(let flavor, let group, _):
            return self.parseGroup(with: flavor, group: group, context: context)
        case .sequence(let subexpressions, _):
            return self.parseSequence(with: subexpressions, context: context)
        case .oneOf(let subexpressions, _):
            return self.parseOneOf(with: subexpressions, context: context)
        case .repeat(let flavor, let expression, _):
            return self.parseRepeat(with: flavor, expression: expression, context: context)
        case .peek(let flavor, let expression, _):
            return self.parsePeek(with: flavor, expression: expression, context: context)
        case .optional(let expression, _):
            return self.parseOptional(with: expression, context: context)
        case .rule(let name, _):
            return self.parseRule(withName: name, context: context)
        }
    }

    private func parseLiteral(with literal: String, context: Context) -> Result? {
        let text = context.text
        let start = context.cursor
        if text.dropFirst(start).starts(with: literal) {
            let position = Result.Position(text, start, start + literal.count)
            return Result(position: position)
        }
        return nil
    }

    private func parseGroup(with flavor: Expression.CharacterGroupFlavor, group: CharacterGroup,
                            context: Context) -> Result?
    {
        guard let character = context.text.dropFirst(context.cursor).first else {
            return nil
        }

        let isInGroup = group.contains(character)

        switch (isInGroup, flavor) {
        case (true, .whitelist), (false, .blacklist):
            let position = Result.Position(context.text, context.cursor, context.cursor + 1)
            return Result(position: position)
        default:
            return nil
        }
    }

    private func parseSequence(with expressions: [Expression], context: Context) -> Result? {
        let text = context.text
        let start = context.cursor
        let nextContext = Context(text: text, position: start, grammar: context.grammar)

        var children = [Result]()

        for expression in expressions {
            guard let result = expression.parse(nextContext) else {
                return nil
            }

            let resultRange = result.position.range
            nextContext.cursor += resultRange.upperBound - resultRange.lowerBound
            children.append(result)
        }

        let position = Result.Position(text, start, nextContext.cursor)
        return Result(position: position, value: .raw(children))
    }

    private func parseOneOf(with expressions: [Expression], context: Context) -> Result? {
        for (index, expression) in expressions.enumerated() {
            if let result = expression.parse(context) {
                return result.with(choice: index)
            }
        }

        return nil
    }

    private func parseRepeat(with flavor: Expression.RepeatFlavor, expression: Expression,
                            context: Context) -> Result?
    {
        let text = context.text
        let start = context.cursor
        let nextContext = Context(text: text, position: start, grammar: context.grammar)
        var children = [Result]()
        while true {
            guard let result = expression.parse(nextContext), !result.position.range.isEmpty else {
                break
            }
            children.append(result)
            nextContext.cursor = result.position.range.upperBound
        }

        if case .oneOrMore = flavor, children.count == 0 {
            return nil
        }

        let position = Result.Position(text, start, nextContext.cursor)
        return Result(position: position, value: .raw(children))
    }

    private func parsePeek(with flavor: Expression.PeekFlavor, expression: Expression,
                          context: Context) -> Result?
    {
        let result = expression.parse(context)
        switch (result, flavor) {
        case (.some, .lookAhead), (.none, .not):
            let position = Result.Position(context.text, context.cursor, context.cursor)
            return Result(position: position)
        default:
            return nil
        }
    }

    private func parseOptional(with expression: Expression, context: Context) -> Result? {
        if let result = expression.parse(context) {
            return Result(position: result.position, choice: 1, value: .raw([result]))
        } else {
            let position = Result.Position(context.text, context.cursor, context.cursor)
            return Result(position: position, choice: 0)
        }
    }

    private func parseRule(withName name: String, context: Context) -> Result? {
        return context
            .grammar
            .rule(byName: name)?
            .expression
            .parse(context)
    }
}
