extension Expression {
    public func parse(_ context: Context) throws -> Node {
        context.trace.append(self)

        let rawNode = try self.parse(raw: context)
        _ = context.trace.popLast()

        guard let convert = self.convert else {
            return rawNode
        }

        do {
            let converted = try convert(rawNode)
            return rawNode.with(value: .converted(converted))
        } catch let error {
            throw ParsingError(expression: self, context: context, reason: .nodeConversionFailure(error))
        }
    }

    private func parse(raw context: Context) throws -> Node {
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

    private func parseLiteral(with literal: String, context: Context) throws -> Node {
        let text = context.text
        let start = context.cursor
        if text.dropFirst(start).starts(with: literal) {
            let position = Node.Position(text, start, start + literal.count)
            return Node(position: position)
        }

        throw ParsingError(expression: self, context: context)
    }

    private func parseGroup(with kind: Expression.CharacterGroupKind, group: CharacterGroup,
                            context: Context) throws -> Node
    {
        guard let character = context.text.dropFirst(context.cursor).first else {
            throw ParsingError(expression: self, context: context, reason: .inputTooShort)
        }

        let isInGroup = group.contains(character)

        switch (isInGroup, kind) {
        case (true, .whitelist), (false, .blacklist):
            let position = Node.Position(context.text, context.cursor, context.cursor + 1)
            return Node(position: position)
        default:
            throw ParsingError(expression: self, context: context)
        }
    }

    private func parseSequence(with expressions: [Expression], context: Context) throws -> Node {
        let text = context.text
        let start = context.cursor
        let nextContext = context.copy()

        var children = [Node]()

        for expression in expressions {
            let node = try expression.parse(nextContext)
            let nodeRange = node.position.range
            nextContext.cursor += nodeRange.upperBound - nodeRange.lowerBound
            children.append(node)
        }

        let position = Node.Position(text, start, nextContext.cursor)
        return Node(position: position, value: .raw(children))
    }

    private func parseOneOf(with expressions: [Expression], context: Context) throws -> Node {
        var subexpressionErrors = [ParsingError]()
        for (index, expression) in expressions.enumerated() {
            do {
                let subNode = try expression.parse(context)
                return Node(position: subNode.position, choice: index, value: .raw([subNode]))
            } catch let error as ParsingError {
                subexpressionErrors.append(error)
            }
        }

        throw ParsingError(expression: self, context: context, children: subexpressionErrors)
    }

    private func parseRepeat(with kind: Expression.RepeatKind, expression: Expression,
                             context: Context) throws-> Node
    {
        let text = context.text
        let start = context.cursor
        let nextContext = context.copy()
        var children = [Node]()
        var lastKnownError = ParsingError(expression: self, context: context)
        while true {
            do {
                let node = try expression.parse(nextContext)
                guard !node.position.range.isEmpty else {
                    break
                }
                children.append(node)
                nextContext.cursor = node.position.range.upperBound
            } catch let error as ParsingError {
                lastKnownError = error
                break
            }
        }

        if case .oneOrMore = kind, children.count == 0 {
            throw ParsingError(expression: self, context: context, children: [lastKnownError])
        }

        let position = Node.Position(text, start, nextContext.cursor)
        return Node(position: position, value: .raw(children))
    }

    private func parsePredicate(with kind: Expression.PredicateKind, expression: Expression,
                                context: Context) throws -> Node
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
            let position = Node.Position(context.text, context.cursor, context.cursor)
            return Node(position: position)
        case (.some(let error), .and):
            throw error
        default:
            throw ParsingError(expression: self, context: context)
        }
    }

    private func parseOptional(with expression: Expression, context: Context) throws -> Node {
        do {
            let node = try expression.parse(context)
            return Node(position: node.position.copy(), choice: 1, value: .raw([node]))
        } catch {
            let position = Node.Position(context.text, context.cursor, context.cursor)
            return Node(position: position, choice: 0)
        }
    }

    private func parseRule(withName name: String, context: Context) throws -> Node {
        return try context.grammar.parse(ruleName: name, context: context)
    }
}
