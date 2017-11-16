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

func ctx(_ text: String) -> Context {
    return Context(text: text, position: 0)
}

let literal = s("aa")

print(literal.convert ?? "nil")
// literal.convert = { result in
//     return result.text + "!"
// }

let converted: String = literal.parse(ctx("aa"))?.converted() ?? "<FAIL>"
print(converted)

let group = c(CharacterGroup(["d"..."g", "p"..."p"]))
let sequence = seq(group, literal, group)
let oneOfExpr = of(group, literal)

let repeatExpr0 = zero(sequence)
print(repeatExpr0.parse(ctx("xxxxxx")) != nil)
print(repeatExpr0.parse(ctx("daafxxxx")) != nil)

let repeatExpr1 = one(oneOfExpr)
print(repeatExpr1.parse(ctx("xxxxxx")) == nil)
print("---")
if let oneOrMoreResult = repeatExpr1.parse(ctx("aadaap")) {
    print(oneOrMoreResult.children.count == 4)
    print(oneOrMoreResult.children.count)
    print(oneOrMoreResult.children[0].text == "aa")
    print(oneOrMoreResult.children[0].choice == 1)
    print(oneOrMoreResult.children[1].text == "d")
    print(oneOrMoreResult.children[1].choice == 0)
    print(oneOrMoreResult.children[2].text == "aa")
    print(oneOrMoreResult.children[2].choice == 1)
    print(oneOrMoreResult.children[3].text == "p")
    print(oneOrMoreResult.children[3].choice == 0)
} else {
    print(false)
}

print(group.parse(Context(text: "aadaap", position: 2)) != nil)
