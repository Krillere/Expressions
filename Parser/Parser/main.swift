//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation
/*
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


var funcs:[String] = [
    "define myFunc: Int a -> Int { }",
    "define mFunc2: Int a, Int b -> Int { }",
    "define split: String str, Char c -> [String] { }",
    "define f1: [String] lst -> String { }",
    "define flatten: [[String]] lsts -> [String] { }",
    "define m: Int a, Int b -> Int { if a > b { a } { b } }",
]

for f in funcs {
    print("Kører test på: '\(f)")
    let ps = Parser(input: f)
    ps.run()
    
    print("\n")
}

 */
let example = try String(contentsOfFile: "/Users/Christian/Desktop/example.expr")
let ps = Parser(input: example)
ps.run()
