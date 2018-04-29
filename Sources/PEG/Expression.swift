public indirect enum Expression {
    public final class Properties {
        var convert: ((Node) throws -> Any)? = nil
        public init() {}
    }

    public enum RepeatKind {
        case zeroOrMore
        case oneOrMore
    }

    public enum PredicateKind {
        case and
        case not
    }

    public enum CharacterGroupKind {
        case whitelist
        case blacklist
    }

    case literal(String, Properties)
    case characterGroup(CharacterGroupKind, CharacterGroup, Properties)
    case sequence([Expression], Properties)
    case oneOf([Expression], Properties)
    case `repeat`(RepeatKind, Expression, Properties)
    case predicate(PredicateKind, Expression, Properties)
    case `optional`(Expression, Properties)
    case rule(String, Properties)

    var properties: Properties {
        switch self {
        case .literal(_,           let p): return p
        case .characterGroup(_, _, let p): return p
        case .sequence(_,          let p): return p
        case .oneOf(_,             let p): return p
        case .repeat(_, _,         let p): return p
        case .predicate(_, _,           let p): return p
        case .optional(_,          let p): return p
        case .rule(_,              let p): return p
        }
    }

    public var convert: ((Node) throws -> Any)? {
        get {
            return self.properties.convert
        }

        nonmutating set {
            return self.properties.convert = newValue
        }
    }
}
