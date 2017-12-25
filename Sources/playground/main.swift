import PEG

let input = """
    Number     <- [0-9]+
"""

let grammar = Grammar(rootName: "Number", input)!
grammar.convert("Number") { Double($0.text)! + 0.01 }

let result = grammar.parse("960000")
print(result?.converted(Double.self) ?? "😡")
