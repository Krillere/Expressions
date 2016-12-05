//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

ParserTables.shared.randomizeNames = false


let args = CommandLine.arguments

// Bail if no input file is specified
if args.count < 2 {
    print("Error: No input file specified.")
    exit(0)
}


do {
    // Read input file and compile
    let path = args[1]
    let cont = try String(contentsOfFile: path)
    Compiler.compile(code: cont)
    
    // Try saving it
    guard let intermediate = Compiler.intermediateCode else { exit(0) }
    do {
        let writePath = NSHomeDirectory()+"/Desktop/intermediate.cpp"
        try intermediate.write(toFile: writePath, atomically: true, encoding: String.Encoding.utf8)
        
        print("To compile and run: g++ -std=c++11 \(writePath) -o exprIntermediate; ./exprIntermediate")
        // g++ -std=c++11 \(writePath) -o exprIntermediate; ./exprIntermediate
    }
    catch {
        print("Error ved gem intermediate: \(error)")
    }
}
catch {
    print("File error: \(error)")
}

/*
if let p = Bundle.main.path(forResource: "empty", ofType: "expr") {
    let cont = try String(contentsOfFile: p)
    Compiler.compile(code: cont)
}
else {
    print("No file found..")
}
*/
