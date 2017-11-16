import PEG

let input = """
    Arithmetic <- Factor AddExpr
    AddExpr    <- ('+' / '-') Factor
    Factor     <- Primary MulExpr
    MulExpr    <- ('*' / '/') Primary
    Primary    <- '(' Primary ')' / Number
    Number     <- [0-9]+
"""

let arithmetic = Grammar(rootName: "Arithmetic", input)
print(arithmetic.parse("1+2*3/(4-5)") ?? "<FAIL>")

func c(_ text: String) -> Context {
    return Context(text: text, position: 0)
}

let literal = s("aa")

print(literal.convert ?? "nil")
literal.convert = { result in
    return result.text + "!"
}

print(
    literal.parse(c("aa"))?.text ?? "<FAIL>",
    literal.parse(c("aab")) ?? "<FAIL>",
    literal.parse(c("aba")) ?? "<FAIL>"
)

let converted: String = literal.parse(c("aa"))?.converted() ?? "<FAIL>"
print(converted)

let group = c(CharacterGroup(["d"..."g", "p"..."p"]))

let sequence = seq(group, literal, group)


if let sequenceResult = sequence.parse(c("daaf")) {
    print(sequenceResult.children.count == 3)
    print(sequenceResult.children[0].text == "d")
    print(sequenceResult.children[1].text == "aa")
    print(sequenceResult.children[2].text == "f")
} else {
    print("false")
}
