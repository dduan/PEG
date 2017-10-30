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
