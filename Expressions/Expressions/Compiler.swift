//
//  Compiler.swift
//  Expressions
//
//  Created by Christian Lundtofte on 03/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class Compiler {
    
    static func compile(code: String) {
        let ps = Parser(input: code)
        ps.run()
        
        let errs = ps.getErrors()
        if errs.count != 0 {
            print("Skipping validation and generation due to parsing errors.")
            return
        }
        
        if let program = ps.getProgram() {
            let filler = ParseTableFiller(program: program)
            filler.run()
            
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
}
