import PEG

let input = """
    Arithmetic <- Factor AddExpr*
    AddExpr    <- ('+' / '-') Factor
    Factor     <- Primary MulExpr*

    MulExpr    <- ('*' / '/') Primary
    Primary    <- '(' Arithmetic ')' / Number
    Number     <- [0-9]+
"""

let result = Grammar._peg.parse(input)
print(result ?? "😡")
