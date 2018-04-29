struct Rule {
    let name: String
    let expression: Expression

    public init(_ name: String, _ expression: Expression) {
        self.name = name
        self.expression = expression
    }

    func parse(_ context: Context) throws -> Node {
        // TODO: maybe say something about this location aka failure is from a rule?
        return try self.expression.parse(context)
    }
}
