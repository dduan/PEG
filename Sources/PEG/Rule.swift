struct Rule {
    let name: String
    let expression: Expression

    public init(_ name: String, _ expression: Expression) {
        self.name = name
        self.expression = expression
    }

    func parse(_ context: Context) -> Result? {
        return self.expression.parse(context)
    }
}
