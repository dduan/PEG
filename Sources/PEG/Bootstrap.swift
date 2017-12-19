func bootstrap() -> [Rule] {
    // .
    let any = not(CharacterGroup([]))

    // EndOfFile  <- !.
    let eof = not(any)

    // EndOfLine  <- ’\r\n’ / ’\n’ / ’\r’
    let eol = of(s("\r\n"), s("\n"), s("\r"))

    // Space      <- ’ ’ / ’\t’ / EndOfLine
    let space = of(s(" "), s("\t"), eof)

    // Comment    <- ’#’ (!EndOfLine .)* EndOfLine
    let comment = seq(
        s("#"),
        zero(
            seq(
                not(eol),
                any
            )
        ),
        eol
    )

    // Spacing    <- (Space / Comment)*
    let spacing = zero(
        of(
            space,
            comment
        )
    )

    // LEFTARROW  <- ’<-’ Spacing
    let leftArrow = seq(s("<-"), spacing)

    // SLASH      <- ’/’ Spacing
    let slash = seq(s("/"), spacing)

    // AND        <- ’&’ Spacing
    let and = seq(s("&"), spacing)

    // NOT        <- ’!’ Spacing
    let notC = seq(s("!"), spacing)

    // QUESTION   <- ’?’ Spacing
    let question = seq(s("?"), spacing)

    // STAR       <- ’*’ Spacing
    let star = seq(s("*"), spacing)

    // PLUS       <- ’+’ Spacing
    let plus = seq(s("+"), spacing)

    // OPEN       <- ’(’ Spacing
    let open = seq(s("("), spacing)

    // CLOSE      <- ’)’ Spacing
    let close = seq(s(")"), spacing)

    // DOT        <- ’.’ Spacing
    let dot = seq(s("."), spacing)

    // Range      <- Char ’-’ Char / Char
    let range = of(
        seq(
            any,
            s("-"),
            any
        ),
        any
    )
    // Class      <- ’[’ '^'? (!’]’ Range)* ’]’ Spacing
    let characterClass = seq(
        s("["),
        maybe(s("^")),
        zero(
            seq(
                not(s("]")),
                range
            )
        ),
        s("]"),
        spacing
    )

    // Literal    <- [’] (![’] Char)* [’] Spacing / ["] (!["] Char)* ["] Spacing
    let literal = of(
        seq(
            s("'"),
            zero(
                seq(
                    not(s("'")),
                    any
                )
            ),
            s("'"),
            spacing
        ),
        seq(
            s("\""),
            zero(
                seq(
                    not(s("\"")),
                    any
                )
            ),
            s("\""),
            spacing
        )
    )

    // IdentStart <- [a-zA-Z_]
    let identStart = c("a"..."z", "A"..."Z", "_"..."_")

    // IdentCont  <- IdentStart / [0-9]
    let identCont = of(
        identStart,
        c("0"..."9")
    )

    // Identifier <- IdentStart IdentCont* Spacing
    let identifier = seq(
        identStart,
        zero(identCont),
        spacing
    )
    let kGrammar = "Grammar"
    let kDefinition = "Definition"
    let kExpression = "Expression"
    let kSequence = "Sequence"
    let kPrefix = "Prefix"
    let kSuffix = "Suffix"
    let kPrimary = "Primary"

    // Primary    <- Identifier !LEFTARROW / OPEN Expression CLOSE / Literal / Class / DOT
    let primary = Rule(
        kPrimary,
        of(
            seq(
                identifier,
                not(leftArrow)
            ),
            seq(
                open,
                ref(kExpression),
                close
            ),
            literal,
            characterClass,
            dot
        )
    )

    // Suffix     <- Primary (QUESTION / STAR / PLUS)?
    let suffix = Rule(
        kSuffix,
        seq(
            ref(kPrimary),
            maybe(
                of(
                    question,
                    star,
                    plus
                )
            )
        )
    )

    // Prefix     <- (AND / NOT)? Suffix
    let prefix = Rule(
        kPrefix,
        seq(
            maybe(
                of(
                    and,
                    notC
                )
            ),
            ref(kSuffix)
        )
    )

    // Sequence   <- Prefix*
    let sequence = Rule(
        kSequence,
        zero(ref(kPrefix))
    )

    // Expression <- Sequence (SLASH Sequence)*
    let expression = Rule(
        kExpression,
        seq(
            ref(kSequence),
            zero(
                seq(
                    slash,
                    ref(kSequence)
                )
            )
        )
    )

    // Definition <- Identifier LEFTARROW Expression
    let definition = Rule(
        kDefinition,
        seq(
            identifier,
            leftArrow,
            ref(kExpression)
        )
    )

    // Grammar    <- Spacing Definition+ EndOfFile
    let grammar = Rule(
        kGrammar,
        seq(
            spacing,
            one(ref(kDefinition)),
            eof
        )
    )

    return [grammar, definition, expression, sequence, prefix, suffix, primary]
}
