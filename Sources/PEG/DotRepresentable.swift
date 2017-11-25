protocol DotRepresentable {
    var dotTitle: String { get }
    var dotChildren: [Self] { get }
}

extension DotRepresentable {
    public var dotRepresentation: String {
        var paths = [(Self, Self)]()
        self.visit(self, &paths)
        let formatted = paths
            .map { (path: (Self, Self)) -> String in
                return "    \"\(path.0.dotTitle)\" -> \"\(path.1.dotTitle)\";"
            }
            .joined(separator: "\n")
            return """
            digraph graphname {
            \(formatted)
            }
            """
    }

    private func visit(_ node: Self, _ paths: inout [(Self, Self)]) {
        for child in node.dotChildren {
            paths.append((node, child))
            visit(child, &paths)
        }
    }
}
