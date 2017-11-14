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

print(CharacterGroup(["a"..."b", "e"..."e", "g"..."i"]))
print(CharacterGroup(["p"..."s", "y"..."z"]).contains("q"))
