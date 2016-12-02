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
    var delegate:TreeWalkerDelegate?
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    func walk() {
        if delegate == nil {
            return
        }
        
        
    }
}
