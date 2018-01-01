public struct ParsingError: Error {
    let expression: Expression
    let context: Context
    let children: [ParsingError]
}
