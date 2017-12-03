extension Result: DotRepresentable {
    var dotTitle: String {
        return self.description
    }

    var dotChildren: [Result] {
        return self.children
    }
}
