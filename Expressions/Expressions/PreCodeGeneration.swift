//
//  PreCodeGeneration.swift
//  Expressions
//
//  Created by Christian Lundtofte on 05/12/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

// Changes a few things in the tree before doing the code generation
class PreCodeGeneration: TreeWalker {
    
    // Handle array literals in expressions
    override func walkExpressionNode(node: ExpressionNode) {
        if !expressionUsesAppend(node: node) { // If the expression does not use append
            return
        }
        
        // Find the block, needed for later usage
        guard let block = findParentBlock(node: node) else { return }
        
        // Change the parameter if one of them is an array literal
        if node.loperand is ArrayLiteralNode {
            let newName = ParserTables.shared.generateNewVariableName()
            ParserTables.shared.nameTranslation[newName] = newName
            
            // Guess the type of the node
            let type = CodeGeneratorHelpers.guessType(node: node.loperand!)
            if let type = type {
                let varDecl = LetVariableNode(type: type, name: newName, value: node.loperand!)
                
                block.expressions.insert(varDecl, at: 0)
            
                // Create the new variable
                let variable = VariableNode(identifier: newName)
                node.loperand = variable
            }
        }
        if node.roperand is ArrayLiteralNode {
            
            let newName = ParserTables.shared.generateNewVariableName()
            ParserTables.shared.nameTranslation[newName] = newName
            
            // Guess the type of the node
            let type = CodeGeneratorHelpers.guessType(node: node.roperand!)
            if let type = type {
                let varDecl = LetVariableNode(type: type, name: newName, value: node.roperand!)
                block.expressions.insert(varDecl, at: 0)
            
                // Create the new variable
                let variable = VariableNode(identifier: newName)
                node.roperand = variable
            }
        }
        
        super.walkExpressionNode(node: node)
    }

    // FIxes variadic calls
    override func walkFunctionCallNode(node: FunctionCallNode) {
        // funcNode is the functionDeclaration
        guard let _ = CodeGeneratorHelpers.determineFunctionNodeForCall(call: node) else { return }
        
        super.walkFunctionCallNode(node: node)
    }
    
    // MARK: Other functions

    //Does the ExpressionNode use the append operator?
    func expressionUsesAppend(node: ExpressionNode) -> Bool {
        guard let op = node.op, let opS = op.op else { return false }
        
        if opS == "++" {
            return true
        }
        
        return false
    }
}
    
