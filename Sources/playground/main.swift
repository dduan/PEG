import PEG

let input = """
    Arithmetic <- Factor AddExpr*
    AddExpr    <- ('+' / '-') Factor
    Factor     <- Primary MulExpr*
    MulExpr    <- ('*' / '/') Primary
    Primary    <- '(' Arithmetic ')' / Number
    Number     <- [0-9]+
"""

let grammar = try Grammar(rootName: "Arithmetic", input)
// let result = try grammar.parse("y")
// print(result)
