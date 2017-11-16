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

let maybeExpr = maybe(literal)
let maybeNoResult = maybeExpr.parse(ctx("xxxx"))

print(maybeNoResult != nil)
print(maybeNoResult?.text.isEmpty == true)

let maybeYesResult = maybeExpr.parse(ctx("aaxx"))

print(maybeYesResult != nil)
print(maybeYesResult?.text == "aa")

