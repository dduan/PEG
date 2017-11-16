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

let converted: String = literal.parse(ctx("aa"))?.converted() ?? "<FAIL>"
print(converted)

let group = c(CharacterGroup(["d"..."g", "p"..."p"]))
let sequence = seq(group, literal, group)

let aheadExpr = ahead(sequence)
print(aheadExpr.parse(ctx("daagxxxxx")) != nil)
print(aheadExpr.parse(ctx("daagxxxxx"))?.text.isEmpty == true)
print(aheadExpr.parse(ctx("xdaagxxxxx")) == nil)

let notExpr = not(sequence)
print(notExpr.parse(ctx("daagxxxxx")) == nil)
print(notExpr.parse(ctx("xdaagxxxxx")) != nil)
print(notExpr.parse(ctx("xdaagxxxxx"))?.text.isEmpty == true)
