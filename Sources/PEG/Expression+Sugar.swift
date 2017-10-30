public func s(_ literal: String) -> Expression {
    return .literal(literal, Expression.Properties())
}

public func not(_ group: CharacterGroup) -> Expression {
    return .characterGroup(.blacklist, group, Expression.Properties())
}

public func c(_ group: CharacterGroup) -> Expression {
    return .characterGroup(.whitelist, group, Expression.Properties())
}

public func seq(_ expressions: [Expression]) -> Expression {
    return .sequence(expressions, Expression.Properties())
}

public func oneOf(_ expressions: [Expression]) -> Expression {
    return .oneOf(expressions, Expression.Properties())
}

public func zero(_ expression: Expression) -> Expression {
    return .repeat(.zeroOrMore, expression, Expression.Properties())
}

public func one(_ expression: Expression) -> Expression {
    return .repeat(.oneOrMore, expression, Expression.Properties())
}

public func ahead(_ expression: Expression) -> Expression {
    return .peek(.lookAhead, expression, Expression.Properties())
}

public func not(_ expression: Expression) -> Expression {
    return .peek(.not, expression, Expression.Properties())
}

public func maybe(_ expression: Expression) -> Expression {
    return .optional(expression, Expression.Properties())
}

public func ref(_ name: String) -> Expression {
    return .rule(name, Expression.Properties())
}
