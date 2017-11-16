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
        default:
            return nil
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
        guard let character = context.text.first else {
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
        let nextContext = Context(text: text, position: start)

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
}
