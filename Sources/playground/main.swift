import PEG

let input = """
    X <- "y" [0-9]
"""

let grammar = try Grammar(rootName: "X", input)
let result = try grammar.parse("y")
print(result)
