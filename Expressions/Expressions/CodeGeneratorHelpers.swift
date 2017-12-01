//
//  CodeGenerationHelpers.swift
//  Expressions
//
//  Created by Christian Lundtofte on 15/12/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class CodeGeneratorHelpers {
    static func guessType(node: Node) -> TypeNode? {
        if node is ArrayLiteralNode {
            guard let node = node as? ArrayLiteralNode else { return NormalTypeNode(full: "void*", type: "void*", nestedLevel: 0) }
            if node.contents.count < 1 {
                return nil
            }
            
            let fnode = node.contents[0]
            if fnode is CharLiteralNode {
                return NormalTypeNode(full: "Char", type: "Char", nestedLevel: 1)
            }
            else if fnode is NumberLiteralNode {
                if let fnode = fnode as? NumberLiteralNode {
                    if fnode.floatValue != nil {
                        return NormalTypeNode(full: "Float", type: "Float", nestedLevel: 1)
                    }
                    else if fnode.intValue != nil {
                        return NormalTypeNode(full: "Int", type: "Int", nestedLevel: 1)
                    }
                }
            }
            else if fnode is ArrayLiteralNode {
                return guessType(node: fnode)
            }
            else if fnode is StringLiteralNode {
                return NormalTypeNode(full: "String", type: "String", nestedLevel: 1)
            }
            else if fnode is FunctionCallNode {
                guard let fnode = fnode as? FunctionCallNode, let identifier = fnode.identifier else { return nil }
                
                // Do we know this function?
                if let decl = ParserTables.shared.functionDeclarations[identifier] {
                    let ret = decl.returnType
                    if ret is NormalTypeNode {
                        let tmp = (ret as! NormalTypeNode).copy() as! NormalTypeNode
                        tmp.numNested = 1
                        
                        return tmp
                    }
                    return ret
                }
                
                // Is it an inline function?
                if let inlineReturnType = getInlineReturnType(identifier: identifier, node: fnode) {
                    
                    // It's an array, set the numNested
                    if inlineReturnType is NormalTypeNode {
                        let tmpType = (inlineReturnType as! NormalTypeNode).copy() as! NormalTypeNode
                        tmpType.numNested = 1
                        
                        return tmpType
                    }
                    
                    return inlineReturnType
                }
            }
            else if fnode is VariableNode {
                guard let fnode = fnode as? VariableNode else { return nil }
                
                return findVariableType(node: fnode)
            }
        }
        else if node is NumberLiteralNode {
            if let node = node as? NumberLiteralNode {
                if node.floatValue != nil {
                    return NormalTypeNode(full: "Float", type: "Float", nestedLevel: 0)
                }
                else if node.intValue != nil {
                    return NormalTypeNode(full: "Int", type: "Int", nestedLevel: 0)
                }
            }
        }
        else if node is StringLiteralNode {
            return NormalTypeNode(full: "String", type: "String", nestedLevel: 0)
        }
        else if node is CharLiteralNode {
            return NormalTypeNode(full: "Char", type: "Char", nestedLevel: 0)
        }
        else if node is BooleanLiteralNode {
            return NormalTypeNode(full: "Bool", type: "Bool", nestedLevel: 0)
        }
        else if node is FunctionCallNode {
            guard let fnode = node as? FunctionCallNode, let identifier = fnode.identifier else { return nil }
            
            // Do we know this function?
            if let decl = ParserTables.shared.functionDeclarations[identifier] {
                return decl.returnType
            }
            
            // Is it an inline function?
            if let inlineReturnType = getInlineReturnType(identifier: identifier, node: fnode) {
                return inlineReturnType
            }
        }
        
        return nil
    }
    
    // Determine (gues..) the type of a literal (Array is guessing, rest is pretty straight forward) (Guess is fine. C++ compiler catches mistakes..)
    static func guessTypeString(node: Node) -> String {
        
        if node is ArrayLiteralNode {
            guard let node = node as? ArrayLiteralNode else { return "" }
            if node.contents.count < 1 {
                return "void*"
            }
            
            let fnode = node.contents[0]
            if fnode is CharLiteralNode {
                return "char"
            }
            else if fnode is NumberLiteralNode {
                if let fnode = fnode as? NumberLiteralNode {
                    if fnode.floatValue != nil {
                        return "float"
                    }
                    else if fnode.intValue != nil {
                        return "int"
                    }
                }
            }
            else if fnode is ArrayLiteralNode {
                let str = "std::vector<"+guessTypeString(node: fnode)+">"
                return str
            }
            else if fnode is StringLiteralNode {
                return "std::vector<char>"
            }
        }
        else if node is NumberLiteralNode {
            if let node = node as? NumberLiteralNode {
                if node.floatValue != nil {
                    return "float"
                }
                else if node.intValue != nil {
                    return "int"
                }
            }
        }
        else if node is StringLiteralNode {
            return "std::vector<char>"
        }
        else if node is CharLiteralNode {
            return "char"
        }
        else if node is BooleanLiteralNode {
            return "bool"
        }
        
        ErrorHandler.shared.error(reason: "No type found for node: \(node), probably an error.", node: node, phase: .CodeGeneration)
        return ""
    }
    
    // Attempt to determine which version of a function is being called (For overloading purposes)
    static func determineFunctionNodeForCall(call: FunctionCallNode) -> FunctionNode? {
        guard let identifier = call.identifier else { return nil }
        let decl = ParserTables.shared.functionDeclarations[identifier]

        return decl
    }
    
    static func getInlineReturnType(identifier: String, node: Node) -> TypeNode? {
        var parent = node.parent
        if parent == nil {
            return nil
        }
        
        // Go up the tree until we find 'let' or 'FunctionNode'. 'Let' might have it defined, or it might be in the parameters
        while parent != nil {
            
            if parent is LetNode {
                guard let parent = parent as? LetNode else { return nil }
                
                for letVar in parent.variables {
                    guard let letIdent = letVar.name, let letType = letVar.type else { continue }
                    
                    if letIdent == identifier && letType is FunctionTypeNode {
                        guard let letType = letType as? FunctionTypeNode else { return nil }
                        return letType.returnType
                    }
                }
            }
            else if parent is LetVariableNode {
                guard let parent = parent as? LetVariableNode, let letIdent = parent.name, let letType = parent.type else { return nil }
                
                if letIdent == identifier && letType is FunctionTypeNode {
                    guard let letType = letType as? FunctionTypeNode else { return nil }
                    return letType.returnType
                }
            }
            else if parent is FunctionNode { // Check parameters
                guard let parent = parent as? FunctionNode else { return nil }
                
                for par in parent.parameters {
                    guard let parIdent = par.identifier else { continue }
                    
                    // Must be a function type
                    if par.type is FunctionTypeNode {
                        guard let type = par.type as? FunctionTypeNode else { continue }
                        
                        if parIdent == identifier { // Name match, return it
                            return type.returnType
                        }
                    }
                }
                
                break // No reason to go further than the function scope
            }
            
            parent = parent!.parent
        }
        
        return nil
    }
    
    static func findVariableType(node: VariableNode) -> TypeNode? {
        guard let identifier = node.identifier else { return nil }
        
        var parent = node.parent
        if parent == nil {
            return nil
        }
        
        // Go up the tree until we find 'let' or 'FunctionNode'. 'Let' might have it defined, or it might be in the parameters
        while parent != nil {
            
            if parent is LetNode {
                guard let parent = parent as? LetNode else { return nil }
                
                for letVar in parent.variables {
                    guard let letName = letVar.name else { continue }
                    
                    if identifier == letName {
                        return letVar.type
                    }
                }
            }
            else if parent is LetVariableNode {
                guard let parent = parent as? LetVariableNode, let letIdent = parent.name, let letType = parent.type else { return nil }
                if letIdent == identifier {
                    return letType
                }
            }
            else if parent is FunctionNode { // Check parameters
                guard let parent = parent as? FunctionNode else { return nil }
                
                for par in parent.parameters {
                    guard let parIdent = par.identifier else { continue }
                    if parIdent == identifier {
                        return par.type
                    }
                }
                
                break // No reason to go further than the function scope
            }
            
            parent = parent!.parent
        }
        
        return nil
    }
}
