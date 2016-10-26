//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

var nums:[String] = [
    "1 + 2",
    "(1 + 2)*3",
    "((2 * 3) + 1)",
    "1 * (2 + 45)",
    "12",
    "1 - 2",
    "-10",
    "1 - -2",
    "1 - (-2)",
]

for test in nums {
    print("Kører test på: '\(test)'")
    let sc = Scanner(input: test)
    let ps = Parser(scanner: sc)
    print("Tal parset: "+String(describing: ps.numberExpression()))
    print("\n")
}


var bools:[String] = [
    "true",
    "(true)",
    "true OR false",
    "true AND true",
    "(true AND false)",
    "(true AND false) OR true",
    "true OR (true AND false)",
]

for test in bools {
    print("Kører test på: '\(test)'")
    let sc = Scanner(input: test)
    let ps = Parser(scanner: sc)
    print("Bool parset: "+String(describing: ps.bool()))
    print("\n")
}

var varDecls:[String] = [
    "var myVar = 1;"
]

for test in varDecls {
    print("Kører test på: '\(test)'")
    let sc = Scanner(input: test)
    let ps = Parser(scanner: sc)
    print("Decl parset: "+String(describing: ps.varDecl()))
    print("\n")
}
