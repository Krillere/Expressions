//
//  ScopeChecker.swift
//  Expressions
//
//  Created by Christian Lundtofte on 29/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ScopeChecker: TreeWalker {

    
    // Check if function is defined
    override func walkFunctionCallNode(node: FunctionCallNode) {
        if let identifier = node.identifier {
            
            // Standard function?
            if ParserTables.shared.functions.contains(identifier) {
                return;
            }
            
            // A regular function, stop looking
            if let _ = ParserTables.shared.functionDeclarations[identifier] {
                return;
            }
            
            // Check if it's a parameter (Function type)
            if isFunctionParameter(identifier: identifier, call: node) {
                return;
            }
            
            // Check if a function is declared in a let-expression
            if isFunctionLet(identifier: identifier, call: node) {
                return;
            }
            
            // Does the function exist on a type? (Not good, but easy and fast.)
            if isTypeFunction(identifier: identifier) {
                return;
            }
            
            
            // Must be undefined. (Hopefully..!)
            ErrorHandler.shared.error(reason: "Unknown identifier: \(identifier)", node: node, phase: .ScopeCheck)
        }
    }

    // MARK: Other functions
    func isFunctionParameter(identifier: String, call: FunctionCallNode) -> Bool {
        if call.parent == nil {
            return false
        }
        
        // Go up the tree to find the function declaration
        var parent = call.parent
        while parent != nil {
            if parent is FunctionNode {
                guard let funcDef = parent as? FunctionNode else { return false }
                
                // Iterate parameters, if one is a function check identifier
                for par in funcDef.parameters {
                    guard let parName = par.identifier else { continue }
                    
                    if par.type is FunctionTypeNode { // We have a function type parameter
                        if parName == identifier {
                            return true
                        }
                    }
                }
                
                break
            }
            
            parent = parent!.parent
        }
        
        return false
    }
    
    func isFunctionLet(identifier: String, call: FunctionCallNode) -> Bool {
        if call.parent == nil {
            return false
        }
        
        var parent = call.parent
        while parent != nil {
            
            if parent is FunctionNode { // We're at the function decl. now, break out
                break
            }
            
            if parent is LetNode { // Found let node (There might be more, so we have to check until FunctionNode
                guard let letNode = parent as? LetNode else { continue }
                for letVar in letNode.variables {
                    guard let name = letVar.name else { continue }
                    
                    if letVar.type is FunctionTypeNode {
                        if name == identifier {
                            return true
                        }
                    }
                }
            }
            
            parent = parent!.parent
        }
        
        return false
    }
    
    func isTypeFunction(identifier: String) -> Bool {
        
        // Naive implementation. (Does not check type of object, checks all types)
        for type in self.program.types {
            for obj in type.variables {
                guard let name = obj.identifier else { continue }
                
                if obj.type is FunctionTypeNode {
                    if name == identifier {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
}
