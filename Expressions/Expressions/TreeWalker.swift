//
//  TreeWalker.swift
//  Expressions
//
//  Created by Christian Lundtofte on 30/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class TreeWalker {
    var program:ProgramNode!
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    func walk() {
        for type in program.types {
            walkObjectTypeNode(node: type)
        }
        
        for function in program.functions {
            walkFunctionNode(node: function)
        }
    }
    
    // MARK: Object types
    func walkObjectTypeNode(node: ObjectTypeNode) {
        for variable in node.variables {
            walkObjectTypeVariableNode(node: variable)
        }
    }
    
    func walkObjectTypeVariableNode(node: ObjectTypeVariableNode) {
        if let type = node.type {
            walkTypeNode(node: type)
        }
    }
    
    
    // MARK: Function
    func walkFunctionNode(node: FunctionNode) {
        for par in node.pars {
            walkParameterNode(node: par)
        }
        
        if let retType = node.retType {
            walkTypeNode(node: retType)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
    }
    
    func walkParameterNode(node: ParameterNode) {
        if let type = node.type {
            walkTypeNode(node: type)
        }
    }
    
    // MARK: Lambda
    func walkLambdaNode(node: LambdaNode) {
        for par in node.pars {
            walkParameterNode(node: par)
        }
        
        if let ret = node.retType {
            walkTypeNode(node: ret)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
        
    }
    
    // MARK: Block
    func walkBlockNode(node: BlockNode) {
        for expr in node.expressions {
            walkExpression(node: expr)
        }
    }
    
    // MARK: Function calls
    func walkFunctionCallNode(node: FunctionCallNode) {
        for par in node.parameters {
            walkExpression(node: par)
        }
    }
    
    // Types
    func walkTypeNode(node: TypeNode) {
        if node is NormalTypeNode {
            walkNormalTypeNode(node: node as! NormalTypeNode)
        }
        else if node is FunctionTypeNode {
            walkFunctionTypeNode(node: node as! FunctionTypeNode)
        }
    }
    
    func walkNormalTypeNode(node: NormalTypeNode) {
    }
    
    func walkFunctionTypeNode(node: FunctionTypeNode) {
        for inp in node.inputs {
            walkTypeNode(node: inp)
        }
        
        if let ret = node.ret {
            walkTypeNode(node: ret)
        }
    }
    
    // MARK: Expressions
    // Expressions (Everything, basically called from here)
    func walkExpression(node: Node) {
        if node is IfElseNode {
            walkIfElseNode(node: node as! IfElseNode)
        }
        else if node is LetNode {
            walkLetNode(node: node as! LetNode)
        }
        else if node is SwitchNode {
            walkSwitchNode(node: node as! SwitchNode)
        }
        else if node is LambdaNode {
            walkLambdaNode(node: node as! LambdaNode)
        }
        
        switch node {
        case is ExpressionNode:
            walkExpressionNode(node: node as! ExpressionNode)
            break
            
        // Literals
        case is NumberLiteralNode:
            walkNumberLiteralNode(node: node as! NumberLiteralNode)
            break
            
        case is VariableNode:
            walkVariableNode(node: node as! VariableNode)
            break
            
        case is BooleanLiteralNode:
            walkBooleanLiteralNode(node: node as! BooleanLiteralNode)
            break
            
        case is FunctionCallNode:
            walkFunctionCallNode(node: node as! FunctionCallNode)
            break
            
        case is ParenthesesExpression:
            walkParenthesesExpressionNode(node: node as! ParenthesesExpression)
            break
            
        case is NegateExpression:
            walkNegateExpressionNode(node: node as! NegateExpression)
            break
            
        case is MinusExpression:
            walkMinusExpressionNode(node: node as! MinusExpression)
            break
            
        case is StringLiteralNode:
            walkStringLiteralNode(node: node as! StringLiteralNode)
            break
            
        case is ArrayLiteralNode:
            walkArrayLiteralNode(node: node as! ArrayLiteralNode)
            break
            
        case is CharLiteralNode:
            walkCharLiteralNode(node: node as! CharLiteralNode)
            break

        default:
            break
        }
    }
    
    
    func walkVariableNode(node: VariableNode) {
    }
    
    func walkNumberLiteralNode(node: NumberLiteralNode) {
    }
    
    func walkBooleanLiteralNode(node: BooleanLiteralNode) {
    }
    
    func walkStringLiteralNode(node: StringLiteralNode) {
    }
    
    func walkCharLiteralNode(node: CharLiteralNode) {
    }
    
    func walkArrayLiteralNode(node: ArrayLiteralNode) {
        
        for contents in node.contents {
            walkExpression(node: contents)
        }
    }
    
    func walkParenthesesExpressionNode(node: ParenthesesExpression) {
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkNegateExpressionNode(node: NegateExpression) {
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkMinusExpressionNode(node: MinusExpression) {
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkOperatorNode(node: OperatorNode) {
    }
    
    // EXPR OP EXPR
    func walkExpressionNode(node: ExpressionNode) {
        
        if let expr = node.loperand {
            walkExpression(node: expr)
        }
        
        if let op = node.op {
            walkOperatorNode(node: op)
        }
        
        if let expr = node.roperand {
            walkExpression(node: expr)
        }
    }
    
    // MARK: If-else
    func walkIfElseNode(node: IfElseNode) {
        
        if let cond = node.condition {
            walkExpression(node: cond)
        }
        
        if let block = node.ifBlock {
            walkBlockNode(node: block)
        }
        
        if let block = node.elseBlock {
            walkBlockNode(node: block)
        }
    }
    
    // MARK: Let
    func walkLetNode(node: LetNode) {
        
        for letVar in node.vars {
            walkLetVariableNode(node: letVar)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
    }
    
    func walkLetVariableNode(node: LetVariableNode) {
        
        if let type = node.type {
            walkTypeNode(node: type)
        }
        
        if let expr = node.value {
            walkExpression(node: expr)
        }
    }
    
    // MARK: Switch
    func walkSwitchNode(node: SwitchNode) {
        
        for switchCase in node.cases {
            walkSwitchCaseNode(node: switchCase)
        }
    }
    
    func walkSwitchCaseNode(node: SwitchCaseNode) {
        
        if let expr = node.expr {
            walkExpression(node: expr)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
    }
    
    func walkElseNode(node: ElseNode) {
    }
    
    
    // MARK: Other
    // Replaces 'replace' in it's parent 'inParent' with 'replacement'
    func replaceNode(replace: Node, inParent: Node, replacement: Node) {
        
        if inParent is ExpressionNode { // 'Expr OP Expr'
            guard let inParent = inParent as? ExpressionNode else { return}
            if inParent.loperand === replace {
                inParent.loperand = replacement
            }
            else if inParent.roperand === replace {
                inParent.roperand = replacement
            }
        }
        else if inParent is LetVariableNode { // 'Int myVar = 1'
            guard let inParent = inParent as? LetVariableNode else { return }
            if inParent.value === replace {
                inParent.value = replacement
            }
        }
        else if inParent is BlockNode {
            guard let inParent = inParent as? BlockNode else { return }
            for n in 0 ..< inParent.expressions.count {
                let expr = inParent.expressions[n]

                if expr === replace {
                    inParent.expressions[n] = replacement
                    break
                }
            }
        }
        else if inParent is FunctionCallNode {
            guard let inParent = inParent as? FunctionCallNode else { return }
            for n in 0 ..< inParent.parameters.count {
                let par = inParent.parameters[n]
                if par === replace {
                    inParent.parameters[n] = replacement
                    break
                }
            }
        }
        else {
            print("Opgiver med type: \(type(of: inParent))")
        }
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
}
