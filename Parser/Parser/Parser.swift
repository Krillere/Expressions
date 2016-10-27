//
//  Parser.swift
//  Parser
//
//  Created by Christian Lundtofte on 25/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ParserError {
    var reason:String?
    var token:Token?
    
    init(reason: String, token: Token) {
        self.reason = reason
        self.token = token
    }
}

class Parser {
    var scanner:Scanner!
    var rootNode:Node?
    var errors:[ParserError] = []
    
    init(input: String) {
        self.scanner = Scanner(input: input)
    }
    
    func run() {
        let node = parseFunction()
        print("Resultat fra parser: "+String(describing:node))
    }
    
    func error(_ reason: String) {
        let error = ParserError(reason: reason, token: scanner.getCurToken())
        errors.append(error)
        
        print("ERROR: "+reason)
    }
    
    // MARK: Funktioner
    func parseFunction() -> FunctionNode {
        let token = scanner.getToken()
        if token.type != .keyword_define {
            error("Expected 'define' keyword!")
            return FunctionNode()
        }
        
        // Navn og :
        let nt = scanner.getToken()
        let funcName = nt.content
        let _ = scanner.getToken() // Kolon før parameters
        
        // Parametre og ->
        let pars = parseParameters()
        let _ = scanner.getToken()
        
        let retType = parseType()
        
        let fc = FunctionNode(identifier: funcName, pars: pars, ret: retType, block: parseBlock())
        return fc
    }
    
    // Blocks
    func parseBlock() -> BlockNode {
        
        let ssquare = scanner.getToken()
        if ssquare.type != .lcurly {
            error("Expected {, got: "+ssquare.content)
        }
        
        let check = scanner.peekToken()
        if check.type == .rcurly {
            error("Block has to return a value!")
            return BlockNode()
        }
        
        let block = BlockNode()
        block.expression = parseExpression()
        
        return block
    }
    
    // Parametre
    func parseParameters() -> [ParameterNode] {
        var res:[ParameterNode] = []
        
        while scanner.peekToken().type != .returns {
            if scanner.peekToken().type == .none {
                error("Error in function declaration, parameter stuff")
                break
            }
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            let type = parseType()
            let name = scanner.getToken()
            
            //print("Parameter lavet med type: \(type), navn: \(name.content)")
            res.append(ParameterNode(type: type, name: name.content))
        }
        
        return res
    }
    
    // Type
    func parseType() -> String {
        let token = scanner.getToken()
        
        // Direkte navngiven type
        if token.type == .string {
            return token.content
        }
        
        var ret = token.content
        var metName = false
        
        while true {
            let tmp = scanner.peekToken()
            if tmp.type == .string {
                if !metName {
                    metName = true
                }
                else {
                    break
                }
            }
            
            if tmp.type != .lsquare && tmp.type != .string && tmp.type != .rsquare {
                break
            }
            
            let tok = scanner.getToken()
            ret.append(tok.content)
        }
        
        return ret
    }

    func parseExpression() -> Node {
        let tmpToken = scanner.peekToken()
        
        if tmpToken.type == .keyword_if {
            print("Block indeholder if-statement")
            return parseIf()
        }
        
        return Node()
    }
    
    
    func parseIf() -> IfElseNode {
        let _ = scanner.getToken()
        
        let ifExpr = parseExpression()
        let ifBlock = parseBlock()
        let elseBlock = parseBlock()
        
        let retNode = IfElseNode(cond: ifExpr, ifBlock: ifBlock, elseBlock: elseBlock)
        return retNode
    }
    
    
    // MARK: Tal og bools
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
