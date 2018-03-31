public func s(_ literal: String) -> Expression {
    return .literal(literal, Expression.Properties())
}

public func not(_ group: CharacterGroup) -> Expression {
    return .characterGroup(.blacklist, group, Expression.Properties())
}

public func c(_ group: CharacterGroup) -> Expression {
    return .characterGroup(.whitelist, group, Expression.Properties())
}

public func not(_ ranges: ClosedRange<Character>...) -> Expression {
    let group = CharacterGroup(ranges)
    return .characterGroup(.blacklist, group, Expression.Properties())
}

public func c(_ ranges: ClosedRange<Character>...) -> Expression {
    let group = CharacterGroup(ranges)
    return .characterGroup(.whitelist, group, Expression.Properties())
}

public func not(_ string: String) -> Expression {
    let group = CharacterGroup(charactersIn: string)
    return .characterGroup(.blacklist, group, Expression.Properties())
}

public func c(_ string: String) -> Expression {
    let group = CharacterGroup(charactersIn: string)
    return .characterGroup(.whitelist, group, Expression.Properties())
}

public func seq(_ expressions: [Expression]) -> Expression {
    return .sequence(expressions, Expression.Properties())
}

public func seq(_ expressions: Expression...) -> Expression {
    return .sequence(expressions, Expression.Properties())
}

public func of(_ expressions: [Expression]) -> Expression {
    return .oneOf(expressions, Expression.Properties())
}

public func of(_ expressions: Expression...) -> Expression {
    return .oneOf(expressions, Expression.Properties())
}

public func zero(_ expression: Expression) -> Expression {
    return .repeat(.zeroOrMore, expression, Expression.Properties())
}

public func one(_ expression: Expression) -> Expression {
    return .repeat(.oneOrMore, expression, Expression.Properties())
}

public func ahead(_ expression: Expression) -> Expression {
    return .predicate(.and, expression, Expression.Properties())
}

public func not(_ expression: Expression) -> Expression {
    return .predicate(.not, expression, Expression.Properties())
}

public func maybe(_ expression: Expression) -> Expression {
    return .optional(expression, Expression.Properties())
}

public func ref(_ name: String) -> Expression {
    return .rule(name, Expression.Properties())
}
