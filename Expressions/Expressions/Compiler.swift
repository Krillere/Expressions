//
//  Compiler.swift
//  Expressions
//
//  Created by Christian Lundtofte on 03/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class CompilerError : CustomStringConvertible {
    
    enum Phase {
        case Parsing
        case ScopeCheck
        case TypeCheck
        case SanityCheck
        case CodeGeneration
    }
    
    var reason:String?
    var token:Token?
    var phase:Phase?
    
    init(reason: String, token: Token) {
        self.reason = reason
        self.token = token
    }
    
    init(reason: String, phase: Phase, node: Node) {
        self.reason = reason
        self.phase = phase
    }
    
    var description: String {
        return self.reason!
    }
}

class Compiler {
    
    static var errors:[CompilerError] = []
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
        
        let tmpCode = stdCode+code

        
        // Run scanner and parser
        let ps = Parser(input: tmpCode)
        let scanErrors = ps.getErrors()
        if scanErrors.count != 0 {
            print("Skipping parsing due to errors in scan.")
            print(scanErrors)
            return
        }
        
        ps.run()
        
        let errs = ps.getErrors()
        if errs.count != 0 {
            print("Skipping validation and generation due to parsing errors.")
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
            if errors.count > 0 {
                print("Skipping type check due to errors during scope checking.")
                print("Scope check errors: \(errors)")
                return
            }
            
            // Type check
            //let type = TypeChecker(program: program)
            //type.walk()
            
            if errors.count > 0 {
                print("Skipping code generation due to errors during type checking.")
                print("Type check errors: \(errors)")
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
            
            if errors.count > 0 {
                print("Errors during code generation.")
                print("Errors: \(errors)")
                return
            }
            
            // Save intermediate code
            let intermediate = generator.getIntermediate()
            self.intermediateCode = intermediate
        }
    }
    
    static func error(reason: String, node: Node, phase: CompilerError.Phase) {
        errors.append(CompilerError(reason: reason, phase: phase, node: node))
    }
}
