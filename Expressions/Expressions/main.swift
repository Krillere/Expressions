//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

//ParserTables.shared.randomizeNames = false

func compile(code: String) {
    let ps = Parser(input: code)
    ps.run()
    
    let errs = ps.getErrors()
    if errs.count != 0 {
        print("Skipping validation and generation due to parsing errors.")
        return
    }
    
    if let program = ps.getProgram() {
        let generator = CodeGenerator(program: program)
        generator.generate()
        
        let intermediate = generator.getIntermediate()
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
}

// Did the user specify a file?
let args = CommandLine.arguments
if args.count == 2 {
    do {
        let path = args[1]
        let cont = try String(contentsOfFile: path)
        compile(code: cont)
    }
    catch {
        print("Error: \(error)")
    }
}
else { // Default. Use an example.
    if let p = Bundle.main.path(forResource: "example7", ofType: "expr") {
        let cont = try String(contentsOfFile: p)
        compile(code: cont)
    }
    else {
        print("Ingen fil fundet..")
    }
}
