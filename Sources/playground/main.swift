import PEG

let input = """
    JSON     <- Space? (Object / Array / String / True / False / Null / Number) Space?
    Object   <- "{" (String ":" JSON ("," String ":" JSON)* / Space?) "}"
    Array    <- "[" (JSON ("," JSON)* / Space?) "]"
    String   <- Space? '"' ([^"] / Escape)* '"' Space?
    Escape   <- "\\\\" (["/\\\\bfnrt] / Unicode)
    Unicode  <- "u" HexDigit HexDigit HexDigit HexDigit
    HexDigit <- [0-9A-Fa-f]
    True     <- "true"
    False    <- "false"
    Null     <- "null"
    Number   <- "-"? Integral Fraction? Exponent?
    Integral <- "0" / [1-9] [0-9]*
    Fraction <- "." [0-9]+
    Exponent <- ("e" / "E") ("+" / "-")? [0-9]+
    Space    <- [ \\t\\r\\n]+
"""

let s = """
{
    "a" : [
        1,
        \t2,
        23e2
    ]
}
"""
let grammar = try Grammar(rootName: "JSON", input)
let result = try grammar.parse(s)
print(result)
