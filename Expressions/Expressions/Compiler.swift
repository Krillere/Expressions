//
//  Compiler.swift
//  Expressions
//
//  Created by Christian Lundtofte on 03/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation


class Compiler {
    
    static var intermediateCode:String?
    
    static func compile(code: String) {
        
        // Include standard functions
        var stdCode = ""
        
        if let p = Bundle.main.path(forResource: "std", ofType: "expr") {
            do {
                let stdCont = try String(contentsOfFile: p)
                stdCode += stdCont
            }
            catch {
                
            }
        }
        
        var tmpCode = stdCode+code

        // Find imports
        let importHandler = ImportHandler(source: tmpCode)
        tmpCode = importHandler.doImports()
        
        
        
        // Run scanner and parser
        let ps = Parser(input: tmpCode)
        if ErrorHandler.shared.errors.count != 0 {
            print("Skipping parsing due to errors in scan.")
            print(ErrorHandler.shared.errors)
            return
        }
        
        ps.run()
        

        if ErrorHandler.shared.errors.count != 0 {
            print("Skipping validation and generation due to parsing errors.")
            print(ErrorHandler.shared.errors)
            return
        }
        
        // Parsing succeeded, continue!
        if let program = ps.getProgram() {
            // Fill ParserTables and find functions before doing anything else
            let filler = ParseTableFiller(program: program)
            filler.run()

            // Scope check (Variables and functions)
            let scope = ScopeChecker(program: program)
            scope.walk()
            
            print("Scope checking completed.")
            if ErrorHandler.shared.errors.count > 0 {
                print("Skipping type check due to errors during scope checking.")
                print("Scope check errors: \(ErrorHandler.shared.errors)")
                return
            }
            
            // Type check
            //let type = TypeChecker(program: program)
            //type.walk()
            
            if ErrorHandler.shared.errors.count > 0 {
                print("Skipping code generation due to errors during type checking.")
                print("Type check errors: \(ErrorHandler.shared.errors)")
                return
            }
            
            // Sanity check
            let sanity = SanityChecker(program: program)
            sanity.walk()
            
            // Pre-code generation changes
            let pregen = PreCodeGeneration(program: program)
            pregen.walk()
            
            // Generate intermediate code
            let generator = CodeGenerator(program: program)
            generator.generate()
            
            if ErrorHandler.shared.errors.count > 0 {
                print("Errors during code generation.")
                print(ErrorHandler.shared.errors)
                return
            }
            
            // Save intermediate code
            let intermediate = generator.getIntermediate()
            self.intermediateCode = intermediate
        }
    }

}
