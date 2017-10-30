public func s(_ literal: String) -> Expression {
    return .literal(literal)
}

public func not(_ group: CharacterGroup) -> Expression {
    return .characterGroup(.blacklist, group)
}

public func c(_ group: CharacterGroup) -> Expression {
    return .characterGroup(.whitelist, group)
}

public func seq(_ expressions: [Expression]) -> Expression {
    return .sequence(expressions)
}

public func oneOf(_ expressions: [Expression]) -> Expression {
    return .oneOf(expressions)
}

public func zero(_ expression: Expression) -> Expression {
    return .repeat(.zeroOrMore, expression)
}

public func one(_ expression: Expression) -> Expression {
    return .repeat(.oneOrMore, expression)
}

public func ahead(_ expression: Expression) -> Expression {
    return .peek(.lookAhead, expression)
}

public func not(_ expression: Expression) -> Expression {
    return .peek(.not, expression)
}

public func maybe(_ expression: Expression) -> Expression {
    return .optional(expression)
}

public func ref(_ name: String) -> Expression {
    return .rule(name)
}
