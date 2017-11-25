extension Expression: DotRepresentable {
    var dotTitle: String {
        switch self {
        case .literal(let s, _):
            return s
        case .characterGroup(let flavor, let group, _):
            let prefix = flavor == .blacklist ? "[^" : "["
            return "\(prefix)\(group)]"
        case .rule(let name, _):
            return "*\(name)"
        case .sequence:
            return "[]"
        case .oneOf:
            return "/"
        case .repeat(let flavor, _, _):
            return flavor == .zeroOrMore ? "*" : "+"
        case .peek(let flavor, _, _):
            return flavor == .lookAhead ? "&" : "!"
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
        case .peek(_, let child, _):
            return [child]
        case .optional(let child, _):
            return [child]
        }
    }
}
