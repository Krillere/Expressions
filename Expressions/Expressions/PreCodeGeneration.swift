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
            let varDecl = LetVariableNode(type: type, name: newName, value: node.loperand!)
            block.expressions.insert(varDecl, at: 0)
            
            // Create the new variable
            let variable = VariableNode(identifier: newName)
            node.loperand = variable
        }
        if node.roperand is ArrayLiteralNode {
            
            let newName = ParserTables.shared.generateNewVariableName()
            ParserTables.shared.nameTranslation[newName] = newName
            
            // Guess the type of the node
            let type = CodeGeneratorHelpers.guessType(node: node.roperand!)
            let varDecl = LetVariableNode(type: type, name: newName, value: node.roperand!)
            block.expressions.insert(varDecl, at: 0)
            
            // Create the new variable
            let variable = VariableNode(identifier: newName)
            node.roperand = variable
        }
        
        super.walkExpressionNode(node: node)
    }

    // MARK: Other functions
    // Finds the BlockNode the 'Node' resides in
    func findParentBlock(node: Node) -> BlockNode? {
        
        var tmpNode = node.parent
        if tmpNode == nil {
            return nil
        }
        
        while tmpNode != nil {
            if tmpNode is BlockNode {
                return tmpNode as? BlockNode
            }
            
            tmpNode = tmpNode!.parent
        }
        
        return nil
    }
    
    //Does the ExpressionNode use the append operator?
    func expressionUsesAppend(node: ExpressionNode) -> Bool {
        guard let op = node.op, let opS = op.op else { return false }
        
        if opS == "++" {
            return true
        }
        
        return false
    }
}
