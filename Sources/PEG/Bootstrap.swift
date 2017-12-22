private func character(fromAnyOrClass result: Result) -> Character {
    guard let character = result.firstCharacter else {
        fatalError("expect character class to have a character in result")
    }
    return character
}

// Char       <- '\\' [nrt'"\\[\\]\\] / !'\\' .
private func character(fromChar char: Result) -> Character {
    return character(fromAnyOrClass: char[1])
}

// Literal    <- [’] (![’] Char)* [’] Spacing / ["] (!["] Char)* ["] Spacing
private func convertLiteral(result: Result) -> Expression {
    let characters = result[1]
        .children
        .map { character(fromChar: $0[1]) }

    return s(String(characters))
}

// Range      <- Char ’-’ Char / Char
private func range(fromRange result: Result) -> ClosedRange<Character> {
    enum Choice: Int { case range = 0; case single = 1 }
    guard let choice = Choice(rawValue: result.choice) else {
        fatalError("expected choice from Range result")
    }

    switch choice {
    case .range:
        let first = character(fromChar: result[0])
        let second = character(fromChar: result[2])
        return first...second
    case .single:
        let char = character(fromChar: result)
        return char...char
    }
}

// Class      <- ’[’ '^'? (!’]’ Range)* ’]’ Spacing
private func convertCharacterClass(result: Result) -> Expression {
    let flavor: Expression.CharacterGroupFlavor = result[1].choice == 0 ? .whitelist : .blacklist
    let ranges = result[2]
        .children
        .map { range(fromRange: $0[1]) }
    return .characterGroup(flavor, CharacterGroup(ranges), Expression.Properties())
}

// IdentStart <- [a-zA-Z_]
// IdentCont  <- IdentStart / [0-9]
// Identifier <- IdentStart IdentCont* Spacing
private func convertIdentifier(result: Result) -> String {
    let groupResults = [result[0]] + result[1].children
    return String(groupResults.map(character(fromAnyOrClass:)))
}

    // EndOfFile  <- !.
    let eof = not(any)

    // EndOfLine  <- ’\r\n’ / ’\n’ / ’\r’
    let eol = of(s("\r\n"), s("\n"), s("\r"))

    // Space      <- ’ ’ / ’\t’ / EndOfLine
    let space = of(s(" "), s("\t"), eol)

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

    // Char       <- '\\' [nrt'"\\[\\]\\] / !'\\' .
    let char = of(
        seq(
            s("\\"),
            c("nrt'\"[]\\")
        ),
        seq(
            not(s("\\")),
            any
        )
    )

    // Range      <- Char ’-’ Char / Char
    let range = of(
        seq(
            char,
            s("-"),
            char
        ),
        char
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

    characterClass.convert = convertCharacterClass

    // Literal    <- [’] (![’] Char)* [’] Spacing / ["] (!["] Char)* ["] Spacing
    let literal = of(
        seq(
            s("'"),
            zero(
                seq(
                    not(s("'")),
                    char
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
                    char
                )
            ),
            s("\""),
            spacing
        )
    )

    literal.convert = convertLiteral

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
