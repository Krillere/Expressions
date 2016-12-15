//
//  PreCodeGeneration.swift
//  Expressions
//
//  Created by Christian Lundtofte on 05/12/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

// Changes a few things in the tree before doing the code generation
class PreCodeGeneration: TreeWalkerDelegate {
    var walker: TreeWalker!
    var program:ProgramNode!
    
    init(program: ProgramNode) {
        self.program = program
        
        self.walker = TreeWalker(program: program, delegate: self)
        self.walker.walk()
    }
    
    // MARK: TreeWalkerDelegate functions
    func visitFunctionNode(node: FunctionNode) {
    }
    
    func visitParameterNode(node: ParameterNode) {
    }
    
    
    func visitObjectTypeNode(node: ObjectTypeNode) {
    }
    
    func visitObjectTypeVariableNode(node: ObjectTypeVariableNode) {
    }
    
    
    func visitLambdaNode(node: LambdaNode) {
    }
    
    
    func visitBlockNode(node: BlockNode) {
    }
    
    
    func visitFunctionCallNode(node: FunctionCallNode) {
    }
    
    
    func visitTypeNode(node: TypeNode) {
    }
    
    func visitNormalTypeNode(node: NormalTypeNode) {
    }
    
    func visitFunctionTypeNode(node: FunctionTypeNode) {
    }
    
    
    func visitVariableNode(node: VariableNode) {
    }
    
    func visitNumberLiteralNode(node: NumberLiteralNode) {
    }
    
    func visitBooleanLiteralNode(node: BooleanLiteralNode) {
    }
    
    func visitStringLiteralNode(node: StringLiteralNode) {
    }
    
    func visitCharLiteralNode(node: CharLiteralNode) {
    }
    
    func visitArrayLiteralNode(node: ArrayLiteralNode) {
    }
    
    func visitParenthesesExpression(node: ParenthesesExpression) {
    }
    
    func visitNegateExpression(node: NegateExpression) {
    }
    
    func visitMinusExpression(node: MinusExpression) {
    }
    
    func visitOperatorNode(node: OperatorNode) {
    }
    
    func visitExpressionNode(node: ExpressionNode) {
        if isAppendExpression(node: node) {
            print("Besøger \(node)")
            
            let varNode = VariableNode(identifier: "test")
            walker.replacementNode = varNode
            walker.replaceNode = true
        }
    }
    
    
    func visitIfElseNode(node: IfElseNode) {
    }
    
    
    func visitLetNode(node: LetNode) {
    }
    
    func visitLetVariableNode(node: LetVariableNode) {
    }
    
    
    func visitSwitchNode(node: SwitchNode) {
    }
    
    func visitSwitchCaseNode(node: SwitchCaseNode) {
    }
    
    func visitElseNode(node: ElseNode) {
    }
    
    
    // MARK: Other functions
    func isAppendExpression(node: ExpressionNode) -> Bool {
        guard let lExpr = node.loperand, let op = node.op else { return false }
        
        var rExpr = node.roperand
        while rExpr != nil {
            guard let opString = op.op else { continue }
            
            
            if opString == "++" {
                return true
            }
            
            // Should we stop or continue? (Continue only if there's more ExpressionNodes)
            if rExpr is ExpressionNode {
                rExpr = (rExpr as! ExpressionNode).roperand
            }
            else {
                rExpr = nil
            }
        }
        
        return false
    }
}
