import PEG

let input = """
    X <- &(("yy")+)
"""

let grammar = try Grammar(rootName: "X", input)
let result = try grammar.parse("y")
print(result)
