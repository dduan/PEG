protocol DotRepresentable {
    var dotTitle: String { get }
    var dotChildren: [Self] { get }
}

extension DotRepresentable {
    typealias Node = (Self, Int)
    public var dotRepresentation: String {
        var paths = [(Node, Node)]()
        var id = 0
        self.visit(self, &paths, &id)
        let formatted = paths
            .map { (path: (Node, Node)) -> String in
                return "    \"\(path.0.1)\n\n\(path.0.0.dotTitle)\" -> \"\(path.1.1)\n\n\(path.1.0.dotTitle)\";"
            }
            .joined(separator: "\n")
            return """
            digraph graphname {
            \(formatted)
            }
            """
    }

    private func visit(_ node: Self, _ paths: inout [(Node, Node)], _ id: inout Int) {
        let parentID = id
        for child in node.dotChildren {
            id += 1
            paths.append(((node, parentID), (child, id)))
            visit(child, &paths, &id)
        }
    }
}
