public final class Context {
    public let text: String
    public var cursor: Int

    public init(text: String, position: Int) {
        self.text = text
        self.cursor = position
    }
}
