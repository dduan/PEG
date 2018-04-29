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
        case .sequence(let subExpressions, _):
            let body = subExpressions
                .map { $0.dotTitle }
                .joined(separator: " , ")
            return "@[\(body)]"
        case .oneOf(let alternatives, _):
            let body = alternatives
                .map { $0.dotTitle }
                .joined(separator: " / ")
            return "(\(body)"
        case .repeat(let kind, let child, _):
            let suffix = kind == .zeroOrMore ? "*" : "+"
            return child.dotTitle + suffix
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
