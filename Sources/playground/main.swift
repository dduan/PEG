import PEG

let input = """
    Arithmetic <- Factor AddExpr*
    AddExpr    <- ('+' / '-') Factor
    Factor     <- Primary MulExpr*
    MulExpr    <- ('*' / '/') Primary
    Primary    <- '(' Arithmetic ')' / Number
    Number     <- [0-9]+
"""

let grammar = Grammar(rootName: "Arithmetic", input)!
let result = grammar.parse("(96+1)/2-100")
print(result ?? "😡")
