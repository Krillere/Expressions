//
//  TreeWalker.swift
//  Expressions
//
//  Created by Christian Lundtofte on 30/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

protocol TreeWalkerDelegate {
    func visitFunctionNode(node: FunctionNode)
    func visitParameterNode(node: ParameterNode)
    
    func visitObjectTypeNode(node: ObjectTypeNode)
    func visitObjectTypeVariableNode(node: ObjectTypeVariableNode)
    
    func visitLambdaNode(node: LambdaNode)
    
    func visitBlockNode(node: BlockNode)
    
    func visitFunctionCallNode(node: FunctionCallNode)
    
    func visitTypeNode(node: TypeNode)
    func visitNormalTypeNode(node: NormalTypeNode)
    func visitFunctionTypeNode(node: FunctionTypeNode)
    
    func visitVariableNode(node: VariableNode)
    func visitNumberLiteralNode(node: NumberLiteralNode)
    func visitBooleanLiteralNode(node: BooleanLiteralNode)
    func visitStringLiteralNode(node: StringLiteralNode)
    func visitCharLiteralNode(node: CharLiteralNode)
    func visitArrayLiteralNode(node: ArrayLiteralNode)
    func visitPropertyValueNode(node: PropertyValueNode)
    func visitParenthesesExpression(node: ParenthesesExpression)
    func visitNegateExpression(node: NegateExpression)
    func visitMinusExpression(node: MinusExpression)
    func visitOperatorNode(node: OperatorNode)
    func visitExpressionNode(node: ExpressionNode)
    
    func visitIfElseNode(node: IfElseNode)
    
    func visitLetNode(node: LetNode)
    func visitLetVariableNode(node: LetVariableNode)
    
    func visitSwitchNode(node: SwitchNode)
    func visitSwitchCaseNode(node: SwitchCaseNode)
    func visitElseNode(node: ElseNode)
}

class TreeWalker {
    var program:ProgramNode!
    var delegate:TreeWalkerDelegate!
    
    init(program: ProgramNode, delegate: TreeWalkerDelegate) {
        self.delegate = delegate
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
        delegate.visitObjectTypeNode(node: node)
        
        for variable in node.variables {
            walkObjectTypeVariableNode(node: variable)
        }
    }
    
    func walkObjectTypeVariableNode(node: ObjectTypeVariableNode) {
        delegate.visitObjectTypeVariableNode(node: node)
        
        if let type = node.type {
            walkTypeNode(node: type)
        }
    }
    
    
    // MARK: Function
    func walkFunctionNode(node: FunctionNode) {
        delegate.visitFunctionNode(node: node)
        
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
        delegate.visitParameterNode(node: node)
        
        if let type = node.type {
            walkTypeNode(node: type)
        }
    }
    
    // MARK: Lambda
    func walkLambdaNode(node: LambdaNode) {
        delegate.visitLambdaNode(node: node)
        
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
        delegate.visitBlockNode(node: node)
        
        for expr in node.expressions {
            walkExpression(node: expr)
        }
    }
    
    // MARK: Function calls
    func walkFunctionCallNode(node: FunctionCallNode) {
        delegate.visitFunctionCallNode(node: node)
        
        for par in node.parameters {
            walkExpression(node: par)
        }
    }
    
    // Types
    func walkTypeNode(node: TypeNode) {
        delegate.visitTypeNode(node: node)
        
        if node is NormalTypeNode {
            walkNormalTypeNode(node: node as! NormalTypeNode)
        }
        else if node is FunctionTypeNode {
            walkFunctionTypeNode(node: node as! FunctionTypeNode)
        }
    }
    
    func walkNormalTypeNode(node: NormalTypeNode) {
        delegate.visitNormalTypeNode(node: node)
    }
    
    func walkFunctionTypeNode(node: FunctionTypeNode) {
        delegate.visitFunctionTypeNode(node: node)
        
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
            
        case is PropertyValueNode:
            walkPropertyValueNode(node: node as! PropertyValueNode)
            break
            
        default:
            break
        }
    }
    
    
    func walkVariableNode(node: VariableNode) {
        delegate.visitVariableNode(node: node)
    }
    
    func walkNumberLiteralNode(node: NumberLiteralNode) {
        delegate.visitNumberLiteralNode(node: node)
    }
    
    func walkBooleanLiteralNode(node: BooleanLiteralNode) {
        delegate.visitBooleanLiteralNode(node: node)
    }
    
    func walkStringLiteralNode(node: StringLiteralNode) {
        delegate.visitStringLiteralNode(node: node)
    }
    
    func walkCharLiteralNode(node: CharLiteralNode) {
        delegate.visitCharLiteralNode(node: node)
    }
    
    func walkArrayLiteralNode(node: ArrayLiteralNode) {
        delegate.visitArrayLiteralNode(node: node)
        
        for contents in node.contents {
            walkExpression(node: contents)
        }
    }
    
    func walkPropertyValueNode(node: PropertyValueNode) {
        delegate.visitPropertyValueNode(node: node)
        
        if let fc = node.call {
            walkFunctionCallNode(node: fc)
        }
    }
    
    func walkParenthesesExpressionNode(node: ParenthesesExpression) {
        delegate.visitParenthesesExpression(node: node)
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkNegateExpressionNode(node: NegateExpression) {
        delegate.visitNegateExpression(node: node)
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkMinusExpressionNode(node: MinusExpression) {
        delegate.visitMinusExpression(node: node)
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkOperatorNode(node: OperatorNode) {
        delegate.visitOperatorNode(node: node)
    }
    
    // EXPR OP EXPR
    func walkExpressionNode(node: ExpressionNode) {
        delegate.visitExpressionNode(node: node)
        
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
        delegate.visitIfElseNode(node: node)
        
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
        delegate.visitLetNode(node: node)
        
        for letVar in node.vars {
            walkLetVariableNode(node: letVar)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
    }
    
    func walkLetVariableNode(node: LetVariableNode) {
        delegate.visitLetVariableNode(node: node)
        
        if let type = node.type {
            walkTypeNode(node: type)
        }
        
        if let expr = node.value {
            walkExpression(node: expr)
        }
    }
    
    // MARK: Switch
    func walkSwitchNode(node: SwitchNode) {
        delegate.visitSwitchNode(node: node)
        
        for switchCase in node.cases {
            walkSwitchCaseNode(node: switchCase)
        }
    }
    
    func walkSwitchCaseNode(node: SwitchCaseNode) {
        delegate.visitSwitchCaseNode(node: node)
        
        if let expr = node.expr {
            walkExpression(node: expr)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
    }
    
    func walkElseNode(node: ElseNode) {
        delegate.visitElseNode(node: node)
    }
}
