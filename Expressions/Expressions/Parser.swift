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
    private var scanner:Scanner!
    private var errors:[ParserError] = []
    private var program:ProgramNode?
    private var errorOccurred = false
    
    init(input: String) {
        self.scanner = Scanner(input: input)
    }
    
    // Parser alle funktioner
    func run() {
        let program = parseProgram()
        self.program = program
        
        var hasEntry = false
        for f in ParserTables.functions {
            if f == "main" {
                hasEntry = true
                break
            }
        }
        
        if !hasEntry {
            errors.append(ParserError(reason: "No entry point found!", token: Token(cont: "", type: .none, charIndex: -1)))
        }
        
        print("Fundet: \(program.functions.count) funktioner!")
        print("Errors: \(errors)")
    }
    
    // Getters
    func getErrors() -> [ParserError] {
        return self.errors
    }
    
    func getProgram() -> ProgramNode? {
        return self.program
    }
    
    
    private func error(_ reason: String) {
        self.errorOccurred = true
        
        let error = ParserError(reason: reason, token: scanner.peekToken())
        errors.append(error)
        
        print("ERROR: "+reason)
    }
    
    // Program
    private func parseProgram() -> ProgramNode {
        var functions:[FunctionNode] = []
        let program = ProgramNode()
        
        while scanner.peekToken().type != .none {
            let node = parseFunction()
            node.parent = program
            functions.append(node)
        }
        
        program.functions = functions
        
        return program
    }
    
    // MARK: Funktioner
    private func parseFunction() -> FunctionNode {
        let token = scanner.getToken()
        if token.type != .keyword_define {
            error("Expected 'define' keyword!")
            return FunctionNode()
        }
        
        // Navn og :
        let nt = scanner.getToken()
        let funcName = nt.content
        
        ParserTables.functions.append(funcName) // Gem funktionsnavn så vi kan tjekke i TypeChecker
        
        let _ = scanner.getToken() // Kolon før parameters
        
        // Parametre og ->
        let pars = parseParameters()
        let _ = scanner.getToken()
        
        let retType = parseType()
        
        let fc = FunctionNode(identifier: funcName, pars: pars, ret: retType.fullString!, block: parseBlock())
        return fc
    }
    
    // Parametre til funktion:   type name, type name ...
    private func parseParameters() -> [ParameterNode] {
        var res:[ParameterNode] = []
        
        while scanner.peekToken().type != .returns {
            if scanner.peekToken().type == .none {
                error("Error in function declaration. Parameters all fucked up.")
                break
            }
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            let type = parseType()
            let name = scanner.getToken()
            
            //print("Parameter lavet med type: \(type), navn: \(name.content)")
            res.append(ParameterNode(type: type.fullString!, name: name.content))
        }
        
        return res
    }
    
    // Blocks { expr }
    private func parseBlock() -> BlockNode {
        
        let ssquare = scanner.getToken()
        if ssquare.type != .lcurly {
            error("Expected {, got: "+ssquare.content)
        }
        
        let check = scanner.peekToken()
        if check.type == .rcurly {
            error("Block has to return a value!")
            return BlockNode()
        }
        
        let block = BlockNode(expr: parseExpression())
        
        let _ = scanner.getToken() // } i block
        
        return block
    }
    
    // Type [String], [[[[[String]]]]], Int, osv.
    private func parseType() -> TypeNode {
        let token = scanner.getToken()
        
        // Direkte navngiven type
        if token.type == .string {
            return TypeNode(full: token.content, type: token.content, nestedLevel: 0)
        }
        
        let ret = TypeNode()
        
        var metName = false
        
        var lParCount = 0
        var rParCount = 0
        
        while true {
            let tmp = scanner.peekToken()
            if tmp.type == .string {
                if !metName {
                    metName = true
                }
                else {
                    ret.clearType = tmp.content
                    break
                }
            }
            
            if tmp.type == .lpar {
                lParCount += 1
            }
            if tmp.type == .rpar {
                rParCount += 1
            }
            
            if tmp.type != .lsquare && tmp.type != .string && tmp.type != .rsquare {
                break
            }
            
            let _ = scanner.getToken()
            //tokenContent.append(tok.content)
        }
        
        if lParCount != rParCount {
            error("Number of square brackets does not match.")
        }
        
        ret.numNested = lParCount
        
        return ret
    }

    // Er det næste udtryk en operator?
    private func isNextOp() -> Bool {
        let tmp = scanner.peekToken()
        return tmp.type == .op
    }
    
    
    // Parser en expression (Største type af alle)
    private func parseExpression() -> Node {
        let tmpToken = scanner.peekToken()
        
        
        // Typer (if, let, switch)
        if tmpToken.type == .keyword_if { // If-else
            return parseIf()
        }
        else if tmpToken.type == .keyword_let { // let vars block
            return parseLet()
        }
        else if tmpToken.type == .keyword_switch { // Snedig if-else
            return parseSwitch()
        }
        else if tmpToken.type == .keyword_else {
            let _ = scanner.getToken() // Fjern 'else'
            return ElseNode()
        }
        
        // Variabler
        var opNode:Node?
        if tmpToken.type == .string { // Variabelnavn (identifier) eller evt. funktionskald?
            let stringToken = scanner.getToken()
            
            let funcCheck = scanner.peekToken()
            if funcCheck.type == .lpar {
                let funcNode = parseFunctionCall(stringToken.content)
                
                if !isNextOp() {
                    return funcNode
                }
                
                opNode = funcNode
            }
            else {
                let variableNode = VariableNode(identifier: stringToken.content)
            
                // Skal der ske mere?
                if !isNextOp() {
                    return variableNode
                }
                
                opNode = variableNode
            }
        }
        else if tmpToken.type == .number { // Tal literal
            let numToken = scanner.getToken()
            var node:NumberLiteralNode?
            
            if numToken.floatValue != nil {
                node = NumberLiteralNode(number: numToken.floatValue!)
            }
            else if numToken.intValue != nil {
                node = NumberLiteralNode(number: numToken.intValue!)
            }
            else {
                error("The fuck..")
            }
            
            // Op?
            if !isNextOp() {
                return node!
            }
            
            opNode = node
        }
        else if tmpToken.type == .boolLiteral { // Bool literal
            let boolToken = scanner.getToken()
            let node = BooleanLiteralNode(value: boolToken.content)
            
            // Op?
            if !isNextOp() {
                return node
            }
            
            opNode = node
        }
        else if tmpToken.type == .lpar {
            let _ = scanner.getToken() // lpar
            let expr = parseExpression()
            let _ = scanner.getToken() // rpar
            
            let parexp = ParenthesesExpression(expr: expr)
            
            if !isNextOp() {
                return parexp
            }
            
            opNode = parexp
        }
        else if tmpToken.type == .stringLiteral {
            let _ = scanner.getToken()
            let expr = StringLiteralNode(content: tmpToken.content)
            
            if !isNextOp() {
                return expr
            }
            
            opNode = expr
        }
        
        if let opNode = opNode {
            let opToken = scanner.getToken()
            let op = OperatorNode(op: opToken.content)
            
            let expr2 = parseExpression()
            return ExpressionNode(op: op, loperand: opNode, roperand: expr2)
        }
        
        return Node()
    }
    
    
    // MARK: Specielle expressions
    // Parser if-else node
    private func parseIf() -> IfElseNode {
        let _ = scanner.getToken() // keyword "if"
        
        let ifExpr = parseExpression()
        let ifBlock = parseBlock()
        let elseBlock = parseBlock()
        
        let retNode = IfElseNode(cond: ifExpr, ifBlock: ifBlock, elseBlock: elseBlock)
        return retNode
    }
    
    // let Int a = 2, String c = "fuck this"
    private func parseLet() -> LetNode {
        let _ = scanner.getToken() // keyword let
        
        let vars = parseLetVariables()
        let block = parseBlock()
        
        return LetNode(vars: vars, block: block)
    }
    
    private func parseLetVariables() -> [LetVariableNode] {
        var res:[LetVariableNode] = []
        
        while scanner.peekToken().type != .lcurly {
            if scanner.peekToken().type == .none {
                error("Error in function declaration. Parameters all fucked up.")
                break
            }
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            let type = parseType()
            let name = scanner.getToken().content
            let _ = scanner.getToken()
            let value = parseExpression()
            
            res.append(LetVariableNode(type: type.fullString!, name: name, value: value))
        }
        
        return res
    }
    
    
    private func parseSwitch() -> SwitchNode {
        let _ = scanner.getToken() // keyword switch
        
        var cases:[SwitchCaseNode] = []
        
        while scanner.peekToken().type != .none {
            let condition = parseExpression()
            let block = parseBlock()
            
            let c = SwitchCaseNode(expr: condition, block: block)
            cases.append(c)
            
            if condition is ElseNode {
                break
            }
        }
        
        return SwitchNode(cases: cases)
    }
    
    
    // MARK: Kald
    func parseFunctionCall(_ identifier: String) -> FunctionCallNode {
        let _ = scanner.getToken() // lpar
        
        let pars:[Node] = parseFunctionCallParameters()
        
        let _ = scanner.getToken() // rpar
        
        return FunctionCallNode(identifier: identifier, parameters: pars)
    }
    
    func parseFunctionCallParameters() -> [Node] {
        var res:[Node] = []
        
        // Kør til vi rammer )
        while scanner.peekToken().type != .rpar {
            if scanner.peekToken().type == .none {
                error("Error in function call. Parameters all fucked up.")
                break
            }
            
            // Ignorer og fjern komma
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            let val = parseExpression()
            
            res.append(val)
        }
        
        return res
    }
}
