public struct Result {
    final class Position {
        let text: String
        let range: Range<Int>

        init(_ text: String, _ start: Int, _ end: Int) {
            self.text = text
            self.range = start..<end
        }
    }

    let position: Position
}
