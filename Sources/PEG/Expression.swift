struct CharacterGroup {}
struct Context {}

indirect enum Expression {
    enum RepeatFlavor {
        case zeroOrMore
        case oneOrMore
    }

    enum PeekFlavor {
        case lookAhead
        case not
    }

    enum CharacterGroupFlavor {
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
    func parse(_ context: Context) -> Result? {
        fatalError()
    }
}
