// TODO: whenever a try? is used in parsing, we should inspect the error thrown from subexpression parsing
// instead of blindly parse forward, even tho failure is acceptable. AKA: figure out specifically which type
// of failures are expected.

extension Expression {
    public func parse(_ context: Context) throws -> Result {
        context.trace.append(self)

        let rawResult = try self.parse(raw: context)
        _ = context.trace.popLast()
        guard let convert = self.convert else {
            return rawResult
        }

        // TODO: throw error
        return rawResult.with(value: .converted(convert(rawResult)))
    }

    private func parse(raw context: Context) throws -> Result {
        switch self {
        case .literal(let literal, _):
            return try self.parseLiteral(with: literal, context: context)
        case .characterGroup(let flavor, let group, _):
            return try self.parseGroup(with: flavor, group: group, context: context)
        case .sequence(let subexpressions, _):
            return try self.parseSequence(with: subexpressions, context: context)
        case .oneOf(let subexpressions, _):
            return try self.parseOneOf(with: subexpressions, context: context)
        case .repeat(let flavor, let expression, _):
            return try self.parseRepeat(with: flavor, expression: expression, context: context)
        case .peek(let flavor, let expression, _):
            return try self.parsePeek(with: flavor, expression: expression, context: context)
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
        // TODO: Add detalis about literal parsing failure
        throw ParsingError(expression: self, context: context, children: [])
    }

    private func parseGroup(with flavor: Expression.CharacterGroupFlavor, group: CharacterGroup,
                            context: Context) throws -> Result
    {
        guard let character = context.text.dropFirst(context.cursor).first else {
            // TODO: details about reaching end of input for groups
            throw ParsingError(expression: self, context: context, children: [])
        }

        let isInGroup = group.contains(character)

        switch (isInGroup, flavor) {
        case (true, .whitelist), (false, .blacklist):
            let position = Result.Position(context.text, context.cursor, context.cursor + 1)
            return Result(position: position)
        default:
            // TODO: add details about group parsing failure?
            throw ParsingError(expression: self, context: context, children: [])
        }
    }

    private func parseSequence(with expressions: [Expression], context: Context) throws -> Result {
        let text = context.text
        let start = context.cursor
        let nextContext = context.copy()

        var children = [Result]()

        for expression in expressions {
            // TODO: details about sequence in error? or is subexpression error enough?
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
                let result = try expression.parse(context)
                return result.with(choice: index)
            } catch let error as ParsingError {
                subexpressionErrors.append(error)
            }
        }

        throw ParsingError(expression: self, context: context, children: subexpressionErrors)
    }

    private func parseRepeat(with flavor: Expression.RepeatFlavor, expression: Expression,
                             context: Context) throws-> Result
    {
        let text = context.text
        let start = context.cursor
        let nextContext = context.copy()
        var children = [Result]()
        var lastKnownError = ParsingError(expression: self, context: context, children: [])
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

        if case .oneOrMore = flavor, children.count == 0 {
            // context contained in this error should have trace that includes this parser as parent. This is
            // enough information to infer what went wrong.
            throw lastKnownError
        }

        let position = Result.Position(text, start, nextContext.cursor)
        return Result(position: position, value: .raw(children))
    }

    private func parsePeek(with flavor: Expression.PeekFlavor, expression: Expression,
                          context: Context) throws -> Result
    {
        let error: Error?
        do {
            _ = try expression.parse(context)
            error = nil
        } catch let parseError {
            error = parseError
        }

        switch (error, flavor) {
        case (.none, .lookAhead), (.some, .not):
            let position = Result.Position(context.text, context.cursor, context.cursor)
            return Result(position: position)
        case (.some(let error), .lookAhead):
            throw error
        default:
            throw ParsingError(expression: self, context: context, children: [])
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
