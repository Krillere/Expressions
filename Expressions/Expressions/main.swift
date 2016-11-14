//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

ParserTables.shared.randomizeNames = false


// Did the user specify a file?
let args = CommandLine.arguments
if args.count == 2 {
    do {
        let path = args[1]
        let cont = try String(contentsOfFile: path)
        Compiler.compile(code: cont)
    }
    catch {
        print("Error: \(error)")
    }
}
else { // Default. Use an example.
    if let p = Bundle.main.path(forResource: "example10", ofType: "expr") {
        let cont = try String(contentsOfFile: p)
        Compiler.compile(code: cont)
    }
    else {
        print("Ingen fil fundet..")
    }
}
