extension Expression {
    public func parse(_ context: Context) throws -> Result {
        context.trace.append(self)

        let rawResult = try self.parse(raw: context)
        _ = context.trace.popLast()

        guard let convert = self.convert else {
            return rawResult
        }

        do {
            let converted = try convert(rawResult)
            return rawResult.with(value: .converted(converted))
        } catch let error {
            throw ParsingError(expression: self, context: context, reason: .resultConversionFailure(error))
        }
    }

    private func parse(raw context: Context) throws -> Result {
        switch self {
        case .literal(let literal, _):
            return try self.parseLiteral(with: literal, context: context)
        case .characterGroup(let kind, let group, _):
            return try self.parseGroup(with: kind, group: group, context: context)
        case .sequence(let subexpressions, _):
            return try self.parseSequence(with: subexpressions, context: context)
        case .oneOf(let subexpressions, _):
            return try self.parseOneOf(with: subexpressions, context: context)
        case .repeat(let kind, let expression, _):
            return try self.parseRepeat(with: kind, expression: expression, context: context)
        case .predicate(let kind, let expression, _):
            return try self.parsePredicate(with: kind, expression: expression, context: context)
        case .optional(let expression, _):
            return try self.parseOptional(with: expression, context: context)
        case .rule(let name, _):
            return try self.parseRule(withName: name, context: context)
        }
    }

    private func parseLiteral(with literal: String, context: Context) throws -> Result {
        let text = context.text
        let start = context.cursor
        if text.dropFirst(start).starts(with: literal) {
            let position = Result.Position(text, start, start + literal.count)
            return Result(position: position)
        }

        throw ParsingError(expression: self, context: context)
    }

    private func parseGroup(with kind: Expression.CharacterGroupKind, group: CharacterGroup,
                            context: Context) throws -> Result
    {
        guard let character = context.text.dropFirst(context.cursor).first else {
            throw ParsingError(expression: self, context: context, reason: .inputTooShort)
        }

        let isInGroup = group.contains(character)

        switch (isInGroup, kind) {
        case (true, .whitelist), (false, .blacklist):
            let position = Result.Position(context.text, context.cursor, context.cursor + 1)
            return Result(position: position)
        default:
            throw ParsingError(expression: self, context: context)
        }
    }

    private func parseSequence(with expressions: [Expression], context: Context) throws -> Result {
        let text = context.text
        let start = context.cursor
        let nextContext = context.copy()

        var children = [Result]()

        for expression in expressions {
            let result = try expression.parse(nextContext)
            let resultRange = result.position.range
            nextContext.cursor += resultRange.upperBound - resultRange.lowerBound
            children.append(result)
        }

        let position = Result.Position(text, start, nextContext.cursor)
        return Result(position: position, value: .raw(children))
    }

    private func parseOneOf(with expressions: [Expression], context: Context) throws -> Result {
        var subexpressionErrors = [ParsingError]()
        for (index, expression) in expressions.enumerated() {
            do {
                let subResult = try expression.parse(context)
                return Result(position: subResult.position, choice: index, value: .raw([subResult]))
            } catch let error as ParsingError {
                subexpressionErrors.append(error)
            }
        }

        throw ParsingError(expression: self, context: context, children: subexpressionErrors)
    }

    private func parseRepeat(with kind: Expression.RepeatKind, expression: Expression,
                             context: Context) throws-> Result
    {
        let text = context.text
        let start = context.cursor
        let nextContext = context.copy()
        var children = [Result]()
        var lastKnownError = ParsingError(expression: self, context: context)
        while true {
            do {
                let result = try expression.parse(nextContext)
                guard !result.position.range.isEmpty else {
                    break
                }
                children.append(result)
                nextContext.cursor = result.position.range.upperBound
            } catch let error as ParsingError {
                lastKnownError = error
                break
            }
        }

        if case .oneOrMore = kind, children.count == 0 {
            throw ParsingError(expression: self, context: context, children: [lastKnownError])
        }

        let position = Result.Position(text, start, nextContext.cursor)
        return Result(position: position, value: .raw(children))
    }

    private func parsePredicate(with kind: Expression.PredicateKind, expression: Expression,
                                context: Context) throws -> Result
    {
        let error: Error?
        do {
            _ = try expression.parse(context)
            error = nil
        } catch let parseError {
            error = parseError
        }

        switch (error, kind) {
        case (.none, .and), (.some, .not):
            let position = Result.Position(context.text, context.cursor, context.cursor)
            return Result(position: position)
        case (.some(let error), .and):
            throw error
        default:
            throw ParsingError(expression: self, context: context)
        }
    }

    private func parseOptional(with expression: Expression, context: Context) throws -> Result {
        do {
            let result = try expression.parse(context)
            return Result(position: result.position.copy(), choice: 1, value: .raw([result]))
        } catch {
            let position = Result.Position(context.text, context.cursor, context.cursor)
            return Result(position: position, choice: 0)
        }
    }

    private func parseRule(withName name: String, context: Context) throws -> Result {
        return try context.grammar.parse(ruleName: name, context: context)
    }
}
