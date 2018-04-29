extension Node: DotRepresentable {
    var dotTitle: String {
        return self.description
    }

    var dotChildren: [Node] {
        return self.children
    }
}
