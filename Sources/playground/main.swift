import PEG

let input = """
    Grammar    <- Spacing Definition+ EndOfFile
    Definition <- Identifier LEFTARROW Expression
    Expression <- Sequence (SLASH Sequence)*
    Sequence   <- Prefix*
    Prefix     <- (AND / NOT)? Suffix
    Suffix     <- Primary (QUESTION / STAR / PLUS)?
    Primary    <- Identifier !LEFTARROW / OPEN Expression CLOSE / Literal / Class / DOT

    Identifier <- IdentStart IdentCont* Spacing
    IdentStart <- [a-zA-Z_]
    IdentCont  <- IdentStart / [0-9]
    Literal    <- ['] (!['] Char)* ['] Spacing / ["] (!["] Char)* ["] Spacing
    Class      <- '[' '^'? (!']' Range)* ']' Spacing
    Range      <- Char '-' Char / Char
    Char       <- '\\' [nrt'"\\[\\]\\\\] / !'\\' .

    LEFTARROW  <- '<-' Spacing
    SLASH      <- '/' Spacing
    AND        <- '&' Spacing
    NOT        <- '!' Spacing
    QUESTION   <- '?' Spacing
    STAR       <- '*' Spacing
    PLUS       <- '+' Spacing
    OPEN       <- '(' Spacing
    CLOSE      <- ')' Spacing
    DOT        <- '.' Spacing

    Spacing    <- (Space / Comment)*
    Comment    <- '#' (!EndOfLine .)* EndOfLine
    Space      <- ' ' / '\t' / EndOfLine
    EndOfLine  <- '\r\n' / '\n' / '\r'
    EndOfFile  <- !.
"""

let result = Grammar._peg.parse(input)
print(result ?? "😡")
