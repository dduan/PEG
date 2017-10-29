import PEG

let input = """
    Arithmetic <- Factor AddExpr
    AddExpr    <- ('+' / '-') Factor
    Factor     <- Primary MulExpr
    MulExpr    <- ('*' / '/') Primary
    Primary    <- '(' Primary ')' / Number
    Number     <- [0-9]+
"""

let arithmetic = Grammer(name: "Arithmetic", input)
print(arithmetic.parse("1+2*3/(4-5)"))
