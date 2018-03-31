extension Expression: CustomStringConvertible {
    public var description: String {
        return self.dotTitle
    }
}

extension Expression: DotRepresentable {
    var dotTitle: String {
        switch self {
        case .literal(let s, _):
            return "\"\(s)\""
        case .characterGroup(let kind, let group, _):
            let prefix = kind == .blacklist ? "[^" : "["
            return "\(prefix)\(group)]"
        case .rule(let name, _):
            return "*\(name)"
        case .sequence:
            return "[]"
        case .oneOf:
            return "/"
        case .repeat(let kind, _, _):
            return kind == .zeroOrMore ? "*" : "+"
        case .predicate(let kind, _, _):
            return kind == .and ? "&" : "!"
        case .optional:
            return "?"
        }
    }

    var dotChildren: [Expression] {
        switch self {
        case .literal, .characterGroup, .rule:
            return []
        case .sequence(let children, _):
            return children
        case .oneOf(let children, _):
            return children
        case .repeat(_, let child, _):
            return [child]
        case .predicate(_, let child, _):
            return [child]
        case .optional(let child, _):
            return [child]
        }
    }
}
