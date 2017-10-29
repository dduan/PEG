public struct CharacterGroup {}

public indirect enum Expression {
    public enum RepeatFlavor {
        case zeroOrMore
        case oneOrMore
    }

    public enum PeekFlavor {
        case lookAhead
        case not
    }

    public enum CharacterGroupFlavor {
        case whitelist
        case blacklist
    }

    case literal(String)
    case characterGroup(CharacterGroupFlavor, CharacterGroup)
    case sequence([Expression])
    case oneOf([Expression])
    case `repeat`(RepeatFlavor, Expression)
    case peek(PeekFlavor, Expression)
    case `optional`(Expression)
    case rule(String)
}

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
        switch self {
        case .literal(let literal):
            return self.parseLiteral(with: literal, context: context)
        default:
            return nil
        }
    }
}
