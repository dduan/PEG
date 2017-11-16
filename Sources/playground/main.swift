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

func ctx(_ text: String) -> Context {
    return Context(text: text, position: 0)
}

let literal = s("aa")

print(literal.convert ?? "nil")
literal.convert = { result in
    return result.text + "!"
}

let converted: String = literal.parse(ctx("aa"))?.converted() ?? "<FAIL>"
print(converted)

let group = c(CharacterGroup(["d"..."g", "p"..."p"]))
let sequence = seq(group, literal, group)
let oneOfExpr = of(group, literal)

print(oneOfExpr.parse(ctx("xxxx")) == nil)
let firstChoiceMatch = oneOfExpr.parse(ctx("p"))
let secondChoiceMatch = oneOfExpr.parse(ctx("aa"))
print(firstChoiceMatch != nil)
print(secondChoiceMatch != nil)
print(firstChoiceMatch?.choice == 0)
print(secondChoiceMatch?.choice == 1)
