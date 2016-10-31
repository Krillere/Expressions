//
//  Parser.swift
//  Parser
//
//  Created by Christian Lundtofte on 25/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

// Parser error class
class ParserError : CustomStringConvertible {
    var reason:String?
    var token:Token?
    
    init(reason: String, token: Token) {
        self.reason = reason
        self.token = token
    }
    
    var description: String {
        return self.reason!
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
    
    // Runs the parser on the input.
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
        
        // No 'main' found
        if !hasEntry {
            errors.append(ParserError(reason: "No entry point found! ('define main: -> Int' missing)", token: Token(cont: "", type: .none, charIndex: -1)))
        }
        
        print("Found: \(program.functions.count) functions!")
        print("Found: \(program.types.count) types!")
        
        print("Errors: \(errors)")
    }
    
    // Getters
    func getErrors() -> [ParserError] {
        return self.errors
    }
    
    func getProgram() -> ProgramNode? {
        return self.program
    }
    
    // MARK: Parser functionality
    
    // Creates an error
    private func error(_ reason: String) {
        self.errorOccurred = true
        
        let error = ParserError(reason: reason, token: scanner.peekToken())
        errors.append(error)
        
        print("ERROR: "+reason)
    }
    
    // Parse program
    private func parseProgram() -> ProgramNode {
        var functions:[FunctionNode] = []
        var objectTypes:[ObjectTypeNode] = []
        let program = ProgramNode()
        
        // Continue as long as input exists
        while scanner.peekToken().type != .none {
            let test = scanner.peekToken()
            
            if test.type == .keyword_type { // Type
                let node = parseObjectType()
                node.parent = program
                
                objectTypes.append(node)
            }
            else if test.type == .keyword_define { // Function
                let node = parseFunction()
                node.parent = program
                
                functions.append(node)
            }
        }
        
        program.functions = functions
        program.types = objectTypes
        
        return program
    }
    
    // Parses an objec type
    private func parseObjectType() -> ObjectTypeNode {
        let t1 = scanner.getToken() // 'type'
        if !t1.content.contains("type") {
            error("Expected 'type', got \(t1.content)")
        }
        
        // Type name
        let name = scanner.getToken()
        ParserTables.types.append(name.content)
        
        let t2 = scanner.getToken() // '{'
        if !t2.content.contains("{") {
            error("Expected '{', got \(t2.content)")
        }
        
        var variables:[ObjectTypeVariableNode] = []
        
        // Finds type variables
        while scanner.peekToken().type != .rcurly {
            let type = parseType()
            let name = scanner.getToken()
            
            let varNode = ObjectTypeVariableNode(identifier: name.content, type: type)
            variables.append(varNode)
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue } // Skip komma
        }
        
        let t3 = scanner.getToken() // '}'
        if !t3.content.contains("}") {
            error("Expected '}', got \(t3.content)")
        }
        
        return ObjectTypeNode(variables: variables, name: name.content)
    }
    
    // MARK: Function
    private func parseFunction() -> FunctionNode {
        let token = scanner.getToken()
        if token.type != .keyword_define {
            error("Expected 'define' keyword!")
            return FunctionNode()
        }
        
        // Name and ':'
        let nt = scanner.getToken()
        let funcName = nt.content
        
        ParserTables.functions.append(funcName) // Gem funktionsnavn så vi kan tjekke i TypeChecker
        
        let t1 = scanner.getToken() // ';'
        if !t1.content.contains(":") {
            error("Expected ':', got \(t1.content)")
        }
        
        // Parametre og ->
        let pars = parseParameters()
        let t2 = scanner.getToken()
        if !t2.content.contains(">") {
            error("Expected '>', got \(t2.content)")
        }
        
        let retType = parseType()
        
        let fc = FunctionNode(identifier: funcName, pars: pars, ret: retType, block: parseBlock())
        return fc
    }
    
    // PParameters for function:   type name, type name ...
    private func parseParameters() -> [ParameterNode] {
        var res:[ParameterNode] = []
        
        while scanner.peekToken().type != .returns {
            if scanner.peekToken().type == .none {
                error("Error in function declaration. Parameters all fucked up.")
                break
            }
            
            // Regular parameter (type name)
            let type = parseType()
            let name = scanner.getToken()
            
            res.append(ParameterNode(type: type, name: name.content))
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
        
        let t1 = scanner.getToken() // } i block
        if !t1.content.contains("}") {
            error("Expected '}', got \(t1.content)")
        }
        
        return block
    }
    
    // Type [String], [[[[[String]]]]], Int, and so on.
    private func parseType() -> TypeNode {
        let token = scanner.getToken()
        
        // Direkte navngiven type
        if token.type == .string {
            return NormalTypeNode(full: token.content, type: token.content, nestedLevel: 0)
        }
        
        // Function type?
        if token.type == .lpar {
            return parseFunctionType()
        }
        
        
        // List of some sort, [Int] [[Int]] or something
        let ret = NormalTypeNode()
        
        var metName = false
        
        var lParCount = 0
        var rParCount = 0
        
        if token.type == .lsquare {
            lParCount += 1
        }
        
        var fullTypeName:String = token.content
        var clearTypeName:String = ""
        
        // Iterer [[ string ]] indtil der kommer string igen, da vi så er færdige!
        while true {
            let tmp = scanner.peekToken()
            
            if tmp.type == .string {
                if !metName {
                    clearTypeName = tmp.content
                    metName = true
                }
                else {
                    break
                }
            }
            
            if tmp.type == .lsquare {
                lParCount += 1
            }
            if tmp.type == .rsquare {
                rParCount += 1
            }
            
            if tmp.type != .lsquare && tmp.type != .string && tmp.type != .rsquare {
                break
            }
            
            let tok = scanner.getToken()
            fullTypeName.append(tok.content)
        }
        
        if lParCount != rParCount {
            error("Number of square brackets does not match.")
        }
        
        ret.fullString = fullTypeName
        ret.numNested = lParCount
        ret.clearType = clearTypeName
    
        
        return ret
    }
    
    // Create function type
    private func parseFunctionType() -> TypeNode {
        var inpTypes:[TypeNode] = []
        
        // Parse input types
        let t = scanner.getToken()
        if t.type != .lpar {
            error("Expected ')', got \(t.content)")
        }
        
        while scanner.peekToken().type != .rpar {
            if scanner.peekToken().type == .none {
                error("Error in function declaration. Syntax all fucked up.")
                break
            }
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            let inpType = parseType()
            inpTypes.append(inpType)
        }
        
        let _ = scanner.getToken() // ')'
        
        let t2 = scanner.getToken()
        if t2.type != .returns {
            error("Expected '->', got \(t2.content)")
        }
        
        // Parse output type
        let retType = parseType()
        
        let _ = scanner.getToken() // ')'
        
        
        print("Fundet funktion med input: \(inpTypes) og output: \(retType)")
        
        // Create type node
        let functionType = FunctionTypeNode()
        functionType.ret = retType
        functionType.inputs = inpTypes
        
        return functionType
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
            let t1 = scanner.getToken() // Fjern 'else'
            if !t1.content.contains("else") {
                error("Expected 'else', got \(t1.content)")
            }
            
            return ElseNode()
        }
        
        // Variabler og literals
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
            let t1 = scanner.getToken() // lpar
            if !t1.content.contains("(") {
                error("Expected '(', got \(t1.content)")
            }
            
            let expr = parseExpression()
            
            let t2 = scanner.getToken() // rpar
            if !t2.content.contains("(") {
                error("Expected ')', got \(t2.content)")
            }
            
            let parexp = ParenthesesExpression(expr: expr)
            
            if !isNextOp() {
                return parexp
            }
            
            opNode = parexp
        }
        else if tmpToken.type == .stringLiteral {
            let t1 = scanner.getToken() // "
            if !t1.content.contains("\"") {
                error("Expected '\"', got \(t1.content)")
            }
            
            let expr = StringLiteralNode(content: tmpToken.content)
            
            if !isNextOp() {
                return expr
            }
            
            opNode = expr
        }
        else if tmpToken.type  == .lsquare {
            return parseArrayLiteral()
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
    func parseArrayLiteral() -> ArrayLiteralNode {
        let t1 = scanner.getToken() // [
        if !t1.content.contains("[") {
            error("Expected '[', got \(t1.content)")
        }
        
        var literalNodes:[Node] = []
        
        while scanner.peekToken().type != .rsquare {
            if scanner.peekToken().type == .none {
                error("Error in array literal.")
                break
            }
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            let expr = parseExpression()
            literalNodes.append(expr)
        }
        
        let _ = scanner.getToken() // I forgot what this is.. Fuck it.
        
        let lit = ArrayLiteralNode(nodes: literalNodes)
        return lit
    }

    
    // Parser if-else node
    private func parseIf() -> IfElseNode {
        let t1 = scanner.getToken() // keyword "if"
        if !t1.content.contains("if") {
            error("Expected 'if', got \(t1.content)")
        }
        
        let ifExpr = parseExpression()
        let ifBlock = parseBlock()
        let elseBlock = parseBlock()
        
        let retNode = IfElseNode(cond: ifExpr, ifBlock: ifBlock, elseBlock: elseBlock)
        return retNode
    }
    
    // let Int a = 2, String c = "fuck this"
    private func parseLet() -> LetNode {
        let t1 = scanner.getToken() // keyword let
        if !t1.content.contains("let") {
            error("Expected 'let', got \(t1.content)")
        }

        let vars = parseLetVariables()
        let block = parseBlock()
        
        return LetNode(vars: vars, block: block)
    }
    
    // Parser variabler i en let
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

            let t1 = scanner.getToken() // =
            if !t1.content.contains("=") {
                error("Expected '=', got \(t1.content)")
            }
            let value = parseExpression()

            let vNode = LetVariableNode(type: type, name: name, value: value)
            
            res.append(vNode)
        }
        
        return res
    }
    
    // Parser en switch, lidt ligesom en række if's
    private func parseSwitch() -> SwitchNode {
        let t1 = scanner.getToken() // keyword switch
        if !t1.content.contains("switch") {
            error("Expected 'switch', got \(t1.content)")
        }
        
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
        let t1 = scanner.getToken() // lpar
        if !t1.content.contains("(") {
            error("Expected '(', got \(t1.content)")
        }
        
        let pars:[Node] = parseFunctionCallParameters()
        
        let t2 = scanner.getToken() // rpar
        if !t2.content.contains(")") {
            error("Expected ')', got \(t2.content)")
        }
        
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
