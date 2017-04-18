//
//  Parser.swift
//  Parser
//
//  Created by Christian Lundtofte on 25/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation


class Parser {
    private var scanner:Scanner!
    private var program:ProgramNode?
    private var errorOccurred = false
    
    init(input: String) {
        self.scanner = Scanner(input: input)
        self.scanner.owner = self
        self.scanner.scan()
    }
    
    // Runs the parser on the input.
    func run() {
        let program = parseProgram()
        self.program = program
        
        // Do we have a main function declared?
        var hasEntry = false
        for f in ParserTables.shared.functions {
            if f == "main" {
                hasEntry = true
                break
            }
        }
        
        // No 'main' found
        if !hasEntry {
            ErrorHandler.shared.errors.append(CompilerError(reason: "No entry point found! ('define main: -> Int' missing)", token: Token(cont: "", type: .none, charIndex: -1)))
        }
        
        print("Parsing completed:")
    }
    
    // Getters

    func getProgram() -> ProgramNode? {
        return self.program
    }
    
    // MARK: Parser functionality
    
    
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
            else {
                error("Unexpected something in program: \(test)")
                break
            }
        }
        
        program.functions = functions
        program.types = objectTypes
        
        return program
    }
    
    // Parses an object type
    private func parseObjectType() -> ObjectTypeNode {
        let t1 = scanner.getToken() // 'type'
        if !t1.content.contains("type") {
            error("Expected 'type', got \(t1.content)")
        }
        
        // Type name
        let name = scanner.getToken()
        ParserTables.shared.types.append(name.content)
        
        let t2 = scanner.getToken() // '{'
        if !t2.content.contains("{") {
            error("Expected '{', got \(t2.content)")
        }
        
        var variables:[ObjectTypeVariableNode] = []
        var parNodes:[ParameterNode] = []
        
        // Finds type variables
        while scanner.peekToken().type != .rcurly {
            let type = parseType()
            let name = scanner.getToken()
            
            let varNode = ObjectTypeVariableNode(identifier: name.content, type: type)
            variables.append(varNode)
            
            parNodes.append(ParameterNode(type: type, name: name.content))
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue } // Skip komma
        }
        
        let t3 = scanner.getToken() // '}'
        if !t3.content.contains("}") {
            error("Expected '}', got \(t3.content)")
        }
        
        let functionNode = FunctionNode(identifier: name.content,
                                        pars: parNodes,
                                        ret: NormalTypeNode(full: "t_"+name.content, type: "t_"+name.content, nestedLevel: 0),
                                        block: BlockNode(exprs: []))
        ParserTables.shared.functionDeclarations[name.content] = [functionNode]
        
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
        
        ParserTables.shared.functions.append(funcName) // Gem funktionsnavn så vi kan tjekke i TypeChecker
        
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
        fc.voidReturn = (retType is NormalTypeNode && (retType as! NormalTypeNode).void)
        
        if fc.voidReturn {
            ParserTables.shared.sideConditionFunctions.append(funcName)
        }
        
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
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            // Regular parameter (type name)
            let type = parseType()
            var variadic = false
            
            if scanner.peekToken().type == .ellipsis {
                let _ = scanner.getToken()
                variadic = true
            }
            let name = scanner.getToken()
            
            let parNode = ParameterNode(type: type, name: name.content)
            parNode.variadic = variadic
            
            res.append(parNode)
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
            // error("Block has to return a value!")
            let _ = scanner.getToken()
            return BlockNode(exprs: [])
        }
        
        var exprs:[Node] = []
        
        while scanner.peekToken().type != .rcurly {
            
            if ErrorHandler.shared.errors.count > 0 {
                break
            }
            
            let t = scanner.peekToken().type
            if t == .none {
                error("Unexpected input in block: \(t)")
                break
            }
            
            let expr = parseExpression()
            if expr is ErrorNode {
                break
            }
            exprs.append(expr)
        }
        
        let block = BlockNode(exprs: exprs)
        
        let t1 = scanner.getToken() // } i block
        if !t1.content.contains("}") {
            error("Expected '}', got \(t1.content)")
        }
        
        return block
    }
    
    // Type [String], [[[[[String]]]]], Int, and so on.
    private func parseType() -> TypeNode {
        let token = scanner.getToken()
        
        // Ellipsis?
        if token.type == .ellipsis {
            return NormalTypeNode(full: "...", type: "...", nestedLevel: 0)
        }
        
        // Named type
        if token.type == .string {
            let type = NormalTypeNode(full: token.content, type: token.content, nestedLevel: 0)
            type.void = (token.content == "Void")
            
            return type
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
        
        ret.void = (clearTypeName == "Void")
        
        ret.fullString = fullTypeName
        ret.numNested = lParCount
        ret.clearType = clearTypeName
    
        
        return ret
    }
    
    // Create function type
    private func parseFunctionType() -> TypeNode {
        var inpTypes:[TypeNode] = []
        
        // Parse input types
        while scanner.peekToken().type != .returns {
            if scanner.peekToken().type == .none {
                error("Error in function type declaration. Syntax all fucked up.")
                break
            }
            
            if scanner.peekToken().type == .comma { let _ = scanner.getToken(); continue }
            
            let inpType = parseType()
            inpTypes.append(inpType)
        }
        
        
        let t2 = scanner.getToken()
        if t2.type != .returns {
            error("Expected '->', got \(t2.content)")
        }
        
        // Parse output type
        let retType = parseType()
        
        let _ = scanner.getToken() // ')'
        
        
        // Create type node
        let functionType = FunctionTypeNode()
        functionType.returnType = retType
        functionType.inputs = inpTypes
        
        return functionType
    }

    
    // Parses an expression (All types of expressions)
    private func parseExpression() -> Node {
        let tmpToken = scanner.peekToken()

        // Special types (if, let, switch)
        if tmpToken.type == .keyword_if { // If-else
            return parseIf()
        }
        else if tmpToken.type == .keyword_let { // let vars block
            return parseLet()
        }
        else if tmpToken.type == .keyword_switch { // Switch case
            return parseSwitch()
        }
        else if tmpToken.type == .keyword_else {
            let t1 = scanner.getToken() // Remove 'else'
            if !t1.content.contains("else") {
                error("Expected 'else', got \(t1.content)")
            }
            
            return ElseNode()
        }
        else if tmpToken.type == .keyword_lambda { // Lambda node
            let t1 = scanner.getToken()
            if !t1.content.contains("lambda") {
                error("Expected 'lambda', got \(t1.content)")
            }
            
            return parseLambda()
        }
        
        // Variables and literals
        var opNode:Node?
        if tmpToken.type == .string { // Name (identifier) or function call or something
            let stringToken = scanner.getToken()
            
            let funcCheck = scanner.peekToken()
            if funcCheck.type == .lpar { // Function call
                let funcNode = parseFunctionCall(stringToken.content)
                
                if !isNextOp() {
                    return funcNode
                }
                
                opNode = funcNode
            }
            else { // variable
                let variableNode = VariableNode(identifier: stringToken.content)
            
                // Operator?
                if !isNextOp() {
                    return variableNode
                }
                
                opNode = variableNode
            }
        }
        else if tmpToken.type == .number { // Number literal
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
        else if tmpToken.type == .negate { // ! EXPR
            let _ = scanner.getToken()
            let e = parseExpression()
            if e is ErrorNode {
                return ErrorNode()
            }
            
            let negNode = NegateExpression(expr: e)
            
            if !isNextOp() {
                return negNode
            }
            
            opNode = negNode
        }
        else if tmpToken.type == .lpar { // ( EXPR )
            let t1 = scanner.getToken() // lpar
            if !t1.content.contains("(") {
                error("Expected '(', got \(t1.content)")
            }
            
            let expr = parseExpression()
            if expr is ErrorNode {
                return ErrorNode()
            }
            
            let t2 = scanner.getToken() // rpar
            if !t2.content.contains(")") {
                error("Expected ')', got \(t2.content)")
            }
            
            let parexp = ParenthesesExpression(expr: expr)
            
            if !isNextOp() {
                return parexp
            }
            
            opNode = parexp
        }
        else if tmpToken.type == .stringLiteral { // String literal
            let stringContent = scanner.getToken()
            let expr = StringLiteralNode(content: stringContent.content)
            
            
            if !isNextOp() {
                return expr
            }
            
            opNode = expr
        }
        else if tmpToken.type == .char {
            let token = scanner.getToken()
            let node = CharLiteralNode(content: token.content)
            
            if !isNextOp() {
                return node
            }
            
            opNode = node
        }
        else if tmpToken.type  == .lsquare { // Array literal
            return parseArrayLiteral()
        }
        else if tmpToken.type == .op { // Operator. Hopefully '-' (Nothing else really makes sense..)
            
            // Expand here if other tokens can be used before an expression (Possibly +, as it doesn't really change anything)
            if tmpToken.content != "-" {
                error("Unexpected operator: \(tmpToken)")
                return ErrorNode()
            }
            
            // Parse the expression after minus
            let _ = scanner.getToken()
            let e = parseExpression()
            if e is ErrorNode {
                return ErrorNode()
            }
            
            let minusNode = MinusExpression(expr: e)
            return minusNode
        }
        
        // If an operator was found, parse the next part of the expression
        if let opNode = opNode {
            let opToken = scanner.getToken()
            let op = OperatorNode(op: opToken.content)
            
            let expr2 = parseExpression()
            if expr2 is ErrorNode {
                return ErrorNode()
            }
            return ExpressionNode(op: op, loperand: opNode, roperand: expr2)
        }
        
        error("Error parsing expression. Got token: \(tmpToken)")
        return ErrorNode()
    }
    
    // MARK: Special expressions
    func parseArrayLiteral() -> Node {
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
            if expr is ErrorNode {
                break
            }
            literalNodes.append(expr)
        }
        
        let _ = scanner.getToken() // I forgot what this is.. Fuck it.
        
        let lit = ArrayLiteralNode(nodes: literalNodes)
        
        if !isNextOp() {
            return lit
        }
        else {
            let opToken = scanner.getToken()
            let op = OperatorNode(op: opToken.content)
            
            let expr2 = parseExpression()
            if expr2 is ErrorNode {
                return ErrorNode()
            }
            return ExpressionNode(op: op, loperand: lit, roperand: expr2)
        }
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
                error("Error in let expression.")
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
            if value is ErrorNode {
                break
            }
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
            if condition is ErrorNode {
                break
            }
            let block = parseBlock()
            
            let c = SwitchCaseNode(expr: condition, block: block)
            cases.append(c)
            
            if condition is ElseNode {
                break
            }
        }
        
        return SwitchNode(cases: cases)
    }
    
    
    // MARK: Function calls
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
    
    // Parses the parameters for a function call
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
            if val is ErrorNode {
                break
            }
            res.append(val)
        }
        
        return res
    }
    
    
    // MARK: Lambda
    func parseLambda() -> LambdaNode {
        let t1 = scanner.getToken()
        if t1.type != .lpar {
            error("Expected '(', got \(t1)")
            return LambdaNode()
        }
        
        let pars = parseParameters()
        
        let t2 = scanner.getToken()
        if !t2.content.contains(">") {
            error("Expected '>', got \(t2.content)")
        }
        
        let retType = parseType()
        
        let t3 = scanner.getToken()
        if t3.type != .rpar {
            error("Expected ')', got \(t3)")
        }
        
        let block = parseBlock()
        
        return LambdaNode(pars: pars, ret: retType, block: block)
    }
    
    
    // MARK: Helpers
    // Er det næste udtryk en operator?
    private func isNextOp() -> Bool {
        let tmp = scanner.peekToken()
        return tmp.type == .op
    }
    
    // Creates an error
    func error(_ reason: String) {
        self.errorOccurred = true
        
        let error = CompilerError(reason: reason, token: scanner.peekToken())
        error.phase = .Parsing
        ErrorHandler.shared.errors.append(error)
        
        print("ERROR: "+reason)
    }
}
