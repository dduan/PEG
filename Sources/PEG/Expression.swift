public indirect enum Expression {
    public final class Properties {
        var convert: ((Result) throws -> Any)? = nil
        public init() {}
    }

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

    case literal(String, Properties)
    case characterGroup(CharacterGroupFlavor, CharacterGroup, Properties)
    case sequence([Expression], Properties)
    case oneOf([Expression], Properties)
    case `repeat`(RepeatFlavor, Expression, Properties)
    case peek(PeekFlavor, Expression, Properties)
    case `optional`(Expression, Properties)
    case rule(String, Properties)

    var properties: Properties {
        switch self {
        case .literal(_,           let p): return p
        case .characterGroup(_, _, let p): return p
        case .sequence(_,          let p): return p
        case .oneOf(_,             let p): return p
        case .repeat(_, _,         let p): return p
        case .peek(_, _,           let p): return p
        case .optional(_,          let p): return p
        case .rule(_,              let p): return p
        }
    }

    public var convert: ((Result) throws -> Any)? {
        get {
            return self.properties.convert
        }

        nonmutating set {
            return self.properties.convert = newValue
        }
    }
}
