// TODO: convert force-unwraps for expression generation to assertions or something.
private func character(fromAnyOrClass result: Result) -> Character {
    guard let character = result.firstCharacter else {
        fatalError("expect character class to have a character in result")
    }
    return character
}

// Char       <- '\\' [nrt'"\\[\\]\\] / !'\\' .
private func character(fromChar char: Result) -> Character {
    enum Choice: Int { case escaped = 0; case normal = 1 }
    guard let choice = Choice(rawValue: char.choice) else {
        fatalError("expected choice from Range result")
    }

    switch (choice, char[0][1].firstCharacter) {
    case (.escaped, .some("n")): return "\n"
    case (.escaped, .some("t")): return "\t"
    case (.escaped, .some("r")): return "\r"
    default:
        return character(fromAnyOrClass: char[0][1])
    }
}

// Literal    <- [’] (![’] Char)* [’] Spacing / ["] (!["] Char)* ["] Spacing
private func convertLiteral(result: Result) -> Expression {
    let characters = result[0][1]
        .children
        .map { character(fromAnyOrClass: $0[1][0]) }

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
        let first = character(fromChar: result[0][0])
        let second = character(fromChar: result[0][2])
        return first...second
    case .single:
        let char = character(fromChar: result[0])
        return char...char
    }
}

// Class      <- ’[’ '^'? (!’]’ Range)* ’]’ Spacing
private func convertCharacterClass(result: Result) -> Expression {
    let kind: Expression.CharacterGroupKind = result[1].choice == 0 ? .whitelist : .blacklist
    let ranges = result[2]
        .children
        .map { range(fromRange: $0[1]) }
    return .characterGroup(kind, CharacterGroup(ranges), Expression.Properties())
}

// IdentStart <- [a-zA-Z_]
// IdentCont  <- IdentStart / [0-9]
// Identifier <- IdentStart IdentCont* Spacing
private func convertIdentifier(result: Result) -> String {
    let groupResults = [result[0]] + result[1].children
    return String(groupResults.map(character(fromAnyOrClass:)))
}

// Sequence   <- Prefix*
private func convertSequence(result: Result) -> Expression {
    if result.children.count == 1 {
        return result[0].converted()!
    }

    return seq(result.children.map { $0.converted(Expression.self)! })
}

// .
private let any = not(CharacterGroup([]))

// Primary    <- Identifier !LEFTARROW / OPEN Expression CLOSE / Literal / Class / DOT
private func convertPrimary(result: Result) -> Expression {
    enum Choice: Int {
        case reference  = 0
        case expression = 1
        case literal    = 2
        case `class`    = 3
        case dot        = 4
    }

    guard let choice = Choice(rawValue: result.choice) else {
        fatalError("expected choice 0-5 from primary expression result")
    }

    switch choice {
    case .reference:
        return ref(result[0][0].converted()!)
    case .expression:
        return result[0][1].converted()!
    case .literal, .class:
        return result[0].converted()!
    case .dot:
        return any
    }
}

// Suffix     <- Primary (QUESTION / STAR / PLUS)?
private func convertSuffix(result: Result) -> Expression {
    guard let primaryExpression = result[0].converted(Expression.self) else {
        fatalError("expected expression from primary parse result")
    }

    enum Modifier: Int { case maybe = 0; case zeroOrMore = 1; case oneOrMore = 2 }

    if result[1].choice == 0 {
        return primaryExpression
    } else if result[1].choice == 1 {
        guard let modifier = Modifier(rawValue: result[1][0].choice) else {
            fatalError("expected modifier from some second half of suffix expression")
        }

        switch modifier {
        case .maybe:
            return maybe(primaryExpression)
        case .oneOrMore:
            return one(primaryExpression)
        case .zeroOrMore:
            return zero(primaryExpression)
        }
    }

    fatalError("unknown choice from second half of suffix expression")
}

// Prefix     <- (AND / NOT)? Suffix
private func convertPrefix(result: Result) -> Expression {
    guard let suffixExpression = result[1].converted(Expression.self) else {
        fatalError("expected expression from prefix parse result")
    }

    enum Modifier: Int { case and = 0; case not = 1 }
    if result[0].choice == 0 {
        return suffixExpression
    } else if result[0].choice == 1 {
        guard let modifier = Modifier(rawValue: result[0][0].choice) else {
            fatalError("expected modifier from some second half of prefix expression")
        }

        switch modifier {
        case .and:
            return ahead(suffixExpression)
        case .not:
            return not(suffixExpression)
        }
    }

    fatalError("unknown choice from second half of prefix expression")
}

// Expression <- Sequence (SLASH Sequence)*
private func convertExpression(result: Result) -> Expression {
    guard let firstExpression = result[0].converted(Expression.self) else {
        fatalError("Expected at least one expression in Expression result")
    }

    if result[1].children.isEmpty {
        return firstExpression
    }

    let otherExpressions = result[1]
        .children // SLASH Sequence
        .map { $0[1].converted(Expression.self)! }

    return of([firstExpression] + otherExpressions)
}

// Definition <- Identifier LEFTARROW Expression
private func convertDefinition(result: Result) -> Rule {
    let name = result[0].converted(String.self)!
    let expression = result[2].converted(Expression.self)!
    return Rule(name, expression)
}

// Grammar    <- Spacing Definition+ EndOfFile
private func convertGrammar(result: Result) -> [Rule] {
    return result[1]
        .children
        .map { $0.converted(Rule.self)! }
}

func bootstrap() -> [Rule] {
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

    identifier.convert = convertIdentifier

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

    primary.expression.convert = convertPrimary

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

    suffix.expression.convert = convertSuffix

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

    prefix.expression.convert = convertPrefix

    // Sequence   <- Prefix*
    let sequence = Rule(
        kSequence,
        zero(ref(kPrefix))
    )

    sequence.expression.convert = convertSequence

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

    expression.expression.convert = convertExpression

    // Definition <- Identifier LEFTARROW Expression
    let definition = Rule(
        kDefinition,
        seq(
            identifier,
            leftArrow,
            ref(kExpression)
        )
    )

    definition.expression.convert = convertDefinition

    // Grammar    <- Spacing Definition+ EndOfFile
    let grammar = Rule(
        kGrammar,
        seq(
            spacing,
            one(ref(kDefinition)),
            eof
        )
    )

    grammar.expression.convert = convertGrammar

    return [grammar, definition, expression, sequence, prefix, suffix, primary]
}
