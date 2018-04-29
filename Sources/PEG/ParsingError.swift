public struct ParsingError: Error {
    public enum Reason {
        case inputMismatch
        case inputTooShort
        case nodeConversionFailure(Error)
    }

    let expression: Expression
    let context: Context
    let children: [ParsingError]
    let reason: Reason

    init(
        expression: Expression,
        context: Context,
        children: [ParsingError] = [],
        reason: Reason = .inputMismatch
    )
    {
        self.expression = expression
        self.context = context
        self.children = children
        self.reason = reason
    }
}
