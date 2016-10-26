//
//  Parser.swift
//  Parser
//
//  Created by Christian Lundtofte on 25/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class Parser {
    var scanner:Scanner!
    
    init(scanner: Scanner) {
        self.scanner = scanner
    }
    
    func run() {
        let node = numberExpression()
        print("Resultat fra parser: "+String(describing:node))
    }
    
    func error(_ reason: String) {
        print("ERROR: "+reason)
    }
    
    func varDecl() -> VarDeclNode {
        let token = scanner.getToken()
        
        if token.type != .keyword_var {
            error("Expected 'var'")
        }
        
        let nt = scanner.getToken()
        print("Nt: \(nt.type), \(nt.content)")
        
        let eq = scanner.getToken()
        if eq.type != .equal {
            error("Expected =")
        }
        
        
        
        return VarDeclNode()
    }
    
    func numberExpression() -> NumberNode {
        let token = scanner.getToken()
        
        if token.type == .lpar { // Start på expression
            let expr = ParNumberExprNode(cont: numberExpression())
            let nt = scanner.getToken()
            
            if nt.type == .none {
                return expr
            }
            else if nt.type == .numOperator {
                let op = NumberOpNode(op: nt.content)
                let operand2 = numberExpression()
                
                let expr = NumberExprNode(op: op,
                                          op1: expr,
                                          op2: operand2)
                return expr
            }
        }
        else if token.type == .number {
            let lit = NumberLitNode(value: token.content)
            let nt = scanner.getToken()
            
            if nt.type == .rpar || nt.type == .none {
                return lit
            }
            else if nt.type == .numOperator {
                let op = NumberOpNode(op: nt.content)
                let operand2 = numberExpression()
                
                let expr = NumberExprNode(op: op,
                                          op1: lit,
                                          op2: operand2)
                return expr
            }
        }
        
        error("Something went wrong ved number")
        return NumberNode(value: "Error")
    }
    
    func bool() -> BoolNode {
        let token = scanner.getToken()
        
        if token.type == .lpar { // Start på expression
            let parExpr = ParBoolExprNode(cont: bool())
            let nt = scanner.getToken()
            
            if nt.type == .none {
                return parExpr
            }
            else if nt.type == .boolOperator {
                let op = BoolOpNode(op: nt.content)
                let operand2 = bool()
                
                let expr = BoolExprNode(op: op,
                                        op1: parExpr,
                                        op2: operand2)
                return expr
            }
        }
        else if token.type == .boolLiteral { // Literal
            let lit = BoolLitNode(value: token.content)
            let nt = scanner.getToken()
            
            if nt.type == .rpar || nt.type == .none { // true) eller true
                return lit
            }
            else if nt.type == .boolOperator { // OP bool
                let op = BoolOpNode(op: nt.content)
                let operand2 = bool()
                
                let expr = BoolExprNode(op: op,
                                        op1: lit,
                                        op2: operand2)
                return expr
            }
        }
        
        error("Something went wrong ved bool.")
        return BoolNode(value: "Error")
    }
    
}
