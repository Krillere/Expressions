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
    print("Trying to read and compile code at: \(path).")
    
    let cont = try String(contentsOfFile: path)
    Compiler.compile(code: cont)
    
    // Try saving it (If no name is specified, save on desktop)
    guard let intermediate = Compiler.intermediateCode else { exit(0) }
    do {
        var writePath = ""
        
        if args.count == 3 {
            writePath = args[2]
        }
        else {
            writePath = NSHomeDirectory()+"/Desktop/intermediate.cpp"
        }
        
        try intermediate.write(toFile: writePath, atomically: true, encoding: String.Encoding.utf8)
        
        // g++ -std=c++11 \(writePath) -o exprIntermediate; ./exprIntermediate
        print("To compile and run: g++ -std=c++11 \(writePath) -o exprIntermediate; ./exprIntermediate")
    }
    catch {
        print("Error ved gem intermediate: \(error)")
    }
}
catch {
    print("File error: \(error)")
}
