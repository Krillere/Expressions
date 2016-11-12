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
    
    static func compile(code: String) {
        let ps = Parser(input: code)
        ps.run()
        
        let errs = ps.getErrors()
        if errs.count != 0 {
            print("Skipping validation and generation due to parsing errors.")
            return
        }
        
        if let program = ps.getProgram() {
            // Fill ParserTables and find functions before doing anything else
            let filler = ParseTableFiller(program: program)
            filler.run()

            // Scope check (Variables and functions)
            let scope = ScopeChecker(program: program)
            scope.test()
            
            if errors.count > 0 {
                print("Skipping type check due to errors during scope checking.")
                print("Scope check errors: \(errors)")
                return
            }
            
            // Type check
            let type = TypeChecker(program: program)
            type.test()
            
            if errors.count > 0 {
                print("Skipping code generation due to errors during type checking.")
                print("Type check errors: \(errors)")
                return
            }
            
            // Generate intermediate code
            let generator = CodeGenerator(program: program)
            generator.generate()
            
            // Save to disc
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
    
    static func error(reason: String, node: Node, phase: CompilerError.Phase) {
        errors.append(CompilerError(reason: reason, phase: phase, node: node))
    }
}
