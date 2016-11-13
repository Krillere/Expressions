//
//  ScopeChecker.swift
//  Expressions
//
//  Created by Christian Lundtofte on 29/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ScopeChecker {
    private var program:ProgramNode?
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    func test() {
        guard let program = self.program else { return }
        
        for f in program.functions {
            guard let block = f.block else { continue }
            testBlock(block: block)
        }
    }
    
    // Tests expressions in a block
    func testBlock(block: BlockNode) {
        for expr in block.expressions {
            testExpression(expr: expr)
        }
    }
    
    // Tests an expression
    func testExpression(expr: Node) {
        
        if expr is FunctionCallNode {
            guard let expr = expr as? FunctionCallNode, let identifier = expr.identifier else { return }
            
            // Unknown function called
            if !ParserTables.shared.functions.contains(identifier) {
                //Compiler.error(reason: "Function '\(identifier)' does not exist.", node: expr, phase: .ScopeCheck)
            }
        }
        else if expr is VariableNode {
            guard let _ = expr as? VariableNode else { return }
            
        }
        else if expr is ExpressionNode {
            guard let _ = expr as? ExpressionNode else { return }
            
        }
        else if expr is ParenthesesExpression {
            if let tmpExpr = (expr as! ParenthesesExpression).expression {
                testExpression(expr: tmpExpr)
            }
        }
        else if expr is SwitchNode {
            guard let _ = expr as? SwitchNode else { return }
            
        }
        else if expr is IfElseNode {
            guard let _ = expr as? IfElseNode else { return }
            
        }
        else if expr is LetNode {
            guard let _ = expr as? LetNode else { return }
            
        }
        // TODO: I hvert fald ArrayLiteral og PropertyValue (Kan indeholde andre variabler)
    }
}
