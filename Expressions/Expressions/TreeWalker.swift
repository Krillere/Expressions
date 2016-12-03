//
//  TreeWalker.swift
//  Expressions
//
//  Created by Christian Lundtofte on 30/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

protocol TreeWalkerDelegate {
    func functionNode(node: FunctionNode)
    func parameterNode(node: ParameterNode)
    
    func objectTypeNode(node: ObjectTypeNode)
    func objectTypeVariableNode(node: ObjectTypeVariableNode)
    
    func lambdaNode(node: LambdaNode)
    
    func blockNode(node: BlockNode)
    
    func functionCallNode(node: FunctionCallNode)
    
    func typeNode(node: TypeNode)
    func normalTypeNode(node: NormalTypeNode)
    func functionTypeNode(node: FunctionTypeNode)
    
    func variableNode(node: VariableNode)
    func numberLiteralNode(node: NumberLiteralNode)
    func booleanLiteralNode(node: BooleanLiteralNode)
    func stringLiteralNode(node: StringLiteralNode)
    func charLiteralNode(node: CharLiteralNode)
    func arrayLiteralNode(node: ArrayLiteralNode)
    func propertyValueNode(node: PropertyValueNode)
    func parenthesesExpression(node: ParenthesesExpression)
    func negateExpression(node: NegateExpression)
    func minusExpression(node: MinusExpression)
    func operatorNode(node: OperatorNode)
    func expressionNode(node: ExpressionNode)
    
    func ifElseNode(node: IfElseNode)
    
    func letNode(node: LetNode)
    func letVariableNode(node: LetVariableNode)
    
    func switchNode(node: SwitchNode)
    func switchCaseNode(node: SwitchCaseNode)
    func elseNode(node: ElseNode)
}

class TreeWalker {
    var program:ProgramNode!
    var delegate:TreeWalkerDelegate!
    
    init(program: ProgramNode, delegate: TreeWalkerDelegate) {
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
        delegate.objectTypeNode(node: node)
        
        for variable in node.variables {
            walkObjectTypeVariableNode(node: variable)
        }
    }
    
    func walkObjectTypeVariableNode(node: ObjectTypeVariableNode) {
        delegate.objectTypeVariableNode(node: node)
        
        if let type = node.type {
            walkTypeNode(node: type)
        }
    }
    
    
    // MARK: Function
    func walkFunctionNode(node: FunctionNode) {
        delegate.functionNode(node: node)
        
        for par in node.pars {
            walkParameterNode(node: par)
        }
        
        if let retType = node.retType {
            walkTypeNode(node: retType)
        }
    }
    
    func walkParameterNode(node: ParameterNode) {
        delegate.parameterNode(node: node)
        
        if let type = node.type {
            walkTypeNode(node: type)
        }
    }
    
    // MARK: Lambda
    func walkLambdaNode(node: LambdaNode) {
        delegate.lambdaNode(node: node)
        
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
        delegate.blockNode(node: node)
        
        for expr in node.expressions {
            walkExpression(node: expr)
        }
    }
    
    // MARK: Function calls
    func walkFunctionCallNode(node: FunctionCallNode) {
        delegate.functionCallNode(node: node)
        
        for par in node.parameters {
            walkExpression(node: par)
        }
    }
    
    // Types
    func walkTypeNode(node: TypeNode) {
        delegate.typeNode(node: node)
        
        if node is NormalTypeNode {
            walkNormalTypeNode(node: node as! NormalTypeNode)
        }
        else if node is FunctionTypeNode {
            walkFunctionTypeNode(node: node as! FunctionTypeNode)
        }
    }
    
    func walkNormalTypeNode(node: NormalTypeNode) {
        delegate.normalTypeNode(node: node)
    }
    
    func walkFunctionTypeNode(node: FunctionTypeNode) {
        delegate.functionTypeNode(node: node)
        
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
        delegate.variableNode(node: node)
    }
    
    func walkNumberLiteralNode(node: NumberLiteralNode) {
        delegate.numberLiteralNode(node: node)
    }
    
    func walkBooleanLiteralNode(node: BooleanLiteralNode) {
        delegate.booleanLiteralNode(node: node)
    }
    
    func walkStringLiteralNode(node: StringLiteralNode) {
        delegate.stringLiteralNode(node: node)
    }
    
    func walkCharLiteralNode(node: CharLiteralNode) {
        delegate.charLiteralNode(node: node)
    }
    
    func walkArrayLiteralNode(node: ArrayLiteralNode) {
        delegate.arrayLiteralNode(node: node)
        
        for contents in node.contents {
            walkExpression(node: contents)
        }
    }
    
    func walkPropertyValueNode(node: PropertyValueNode) {
        delegate.propertyValueNode(node: node)
        
        if let fc = node.call {
            walkFunctionCallNode(node: fc)
        }
    }
    
    func walkParenthesesExpressionNode(node: ParenthesesExpression) {
        delegate.parenthesesExpression(node: node)
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkNegateExpressionNode(node: NegateExpression) {
        delegate.negateExpression(node: node)
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkMinusExpressionNode(node: MinusExpression) {
        delegate.minusExpression(node: node)
        
        if let expr = node.expression {
            walkExpression(node: expr)
        }
    }
    
    func walkOperatorNode(node: OperatorNode) {
        delegate.operatorNode(node: node)
    }
    
    // EXPR OP EXPR
    func walkExpressionNode(node: ExpressionNode) {
        delegate.expressionNode(node: node)
        
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
        delegate.ifElseNode(node: node)
        
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
        delegate.letNode(node: node)
        
        for letVar in node.vars {
            walkLetVariableNode(node: letVar)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
    }
    
    func walkLetVariableNode(node: LetVariableNode) {
        delegate.letVariableNode(node: node)
        
        if let type = node.type {
            walkTypeNode(node: type)
        }
        
        if let expr = node.value {
            walkExpression(node: expr)
        }
    }
    
    // MARK: Switch
    func walkSwitchNode(node: SwitchNode) {
        delegate.switchNode(node: node)
        
        for switchCase in node.cases {
            walkSwitchCaseNode(node: switchCase)
        }
    }
    
    func walkSwitchCaseNode(node: SwitchCaseNode) {
        delegate.switchCaseNode(node: node)
        
        if let expr = node.expr {
            walkExpression(node: expr)
        }
        
        if let block = node.block {
            walkBlockNode(node: block)
        }
    }
    
    func walkElseNode(node: ElseNode) {
        delegate.elseNode(node: node)
    }
}
