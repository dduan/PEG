extension Expression {
    func parseLiteral(with literal: String, context: Context) -> Result? {
        let text = context.text
        let start = context.cursor
        if text.dropFirst(start).starts(with: literal) {
            let position = Result.Position(text, start, start + literal.count)
            return Result(position: position)
        }
        return nil
    }

    public func parse(_ context: Context) -> Result? {
        guard let rawResult = self.parse(raw: context) else {
            return nil
        }

        guard let convert = self.convert else {
            return rawResult
        }

        return rawResult.with(value: .converted(convert(rawResult)))
    }

    func parse(raw context: Context) -> Result? {
        switch self {
        case .literal(let literal, _):
            return self.parseLiteral(with: literal, context: context)
        default:
            return nil
        }
    }
}
