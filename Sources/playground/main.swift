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

let literal = Expression.literal("aa")
print(
    literal.parse(c("aa"))?.text ?? "<FAIL>",
    literal.parse(c("aab")) ?? "<FAIL>",
    literal.parse(c("aba")) ?? "<FAIL>"
)
