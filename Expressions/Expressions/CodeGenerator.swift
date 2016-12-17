//
//  CodeGenerator.swift
//  Parser
//
//  Created by Christian Lundtofte on 28/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation


/*
    Every function creates a string containing for example function calls, types and such. 
    The program is generated by creating all types and functions.
*/
class CodeGenerator {
    internal var internalCode:String = ""
    internal var program:ProgramNode?
    internal var doingMainBlock = false
    
    // Prototypes
    internal var declaredFunctions:[String] = []
    
    // Direct conversions, used when possible (Not user-defined types) (Types and operators)
    internal var typeConversions:[String: String] = ["Int":"int", "Char":"char", "Float":"float", "String":"std::vector<char>", "Bool":"bool"]
    internal var opConversions:[String: String] = ["AND":"&&", "OR":"||", ".":"->", "++":"<<"]
    
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    // MARK: General functions
    // Creates and saves code at ~/Desktop/intermediate.cpp
    func generate() {
        guard let program = self.program else { return }
        
        
        // Create standard lib, prototypes, types and functions
        
        // Stdlib
        var stds = ""
        do {
            if let path = Bundle.main.path(forResource: "std", ofType: "cpp") {
                let stdFuncs = try String(contentsOfFile: path)
                stds += stdFuncs
            }
        }
        catch { }
        
        
        let functions = program.functions
        let objTypes = program.types
        
        var typeString = ""
        var funcsString = ""
        
        // Generate types
        for objType in objTypes {
            typeString += createObjectType(objType: objType)
        }
        
        
        // Generate functions
        for function in functions {
            funcsString += createFunction(function: function)
        }
        
        // Prototypes
        var decls = ""
        for dec in declaredFunctions {
            decls += dec+";\n"
        }
        
        emit(stds)
        
        emit("\n// Prototypes \n")
        emit(decls)
        
        emit("\n// Types: \n")
        emit(typeString)
        
        emit("\n// Functions: \n")
        emit(funcsString)
        
        //print("Code:")
        //print(internalCode)
    }
    
    func getIntermediate() -> String {
        return self.internalCode
    }
    
    internal func emit(_ str: String) {
        internalCode += str
    }
    
    // MARK: Type declarations
    // Generates a type declaration
    internal func createObjectType(objType: ObjectTypeNode) -> String {
        guard let name = objType.name else { return "" }
        var ret = ""
        
        // Type declaration
        var typeDecl = "struct t_"+name+" {\n"
        
        for v in objType.variables {
            guard let ttype = v.type, let vname = v.identifier else { continue }
            
            // Normal type
            if ttype is NormalTypeNode {
                guard let ttype = ttype as? NormalTypeNode else { return "" }
                
                let type = createTypeString(type: ttype)
                typeDecl += " "+type+" "+vname+";\n"
            }
            else if ttype is FunctionTypeNode { // Function type
                guard let ttype = ttype as? FunctionTypeNode else { return "" }
                
                let typeString = createFunctionTypeString(type: ttype)
                typeDecl += " "+typeString+" "+vname+";\n"
            }
            
            
        }
        
        typeDecl += "};"
        ret += typeDecl
        
        declaredFunctions.append("struct t_"+name)
        
        // Initialization function
        
        // Function definition
        var typeInit = "t_"+name+" *"+name+"("
        for n in 0 ..< objType.variables.count {
            let v = objType.variables[n]
            guard let ttype = v.type, let vname = v.identifier else { continue }
            
            if ttype is NormalTypeNode {
                guard let ttype = ttype as? NormalTypeNode else { return "" }
                let type = createTypeString(type: ttype)
                typeInit += type+" "+vname
            }
            else if ttype is FunctionTypeNode {
                guard let ttype = ttype as? FunctionTypeNode else { return "" }
                
                let typeString = createFunctionTypeString(type: ttype)

                typeInit += typeString+" "+vname
            }
            
            if n != objType.variables.count-1 {
                typeInit += ", "
            }
        }
        typeInit += ")"
        
        declaredFunctions.append(typeInit)
        
        
        // Function block
        typeInit += " {\n"
        
        typeInit += "t_"+name+" *t_tmp = new t_"+name+";"
        for n in 0 ..< objType.variables.count {
            let v = objType.variables[n]
            guard let vname = v.identifier else { continue }
            
            typeInit += "t_tmp->"+vname+" = "+vname+";\n"
        }
        
        typeInit += "return t_tmp;"
        
        typeInit += "}\n"
        
         ret += "\n"+typeInit
        
        return ret
    }

    
    // MARK: Function declarations
    // Generates a function declaration
    internal func createFunction(function: FunctionNode) -> String {
        guard let retType = function.retType,
            let identifier = function.identifier,
            let block = function.block else { return "" }
        
        
        let genCheck = TreeHelper.isGenericFunction(node: function)
        if genCheck {
            return createGenericFunction(function: function)
        }
        else {
            var ret = ""
            
            if identifier == "main" { // Main has some special parameters (arguments)
                let declaredFunction:String = "int main(int argc, char *argv[])"
                declaredFunctions.append(declaredFunction)
                
                doingMainBlock = true
                let funcDecl:String = "\n"+declaredFunction+createBlock(block: block)
                ret += funcDecl
            }
            else {
                var type = ""
                if retType is NormalTypeNode {
                    type = createTypeString(type: retType as! NormalTypeNode)
                }
                else if retType  is FunctionTypeNode {
                    type = createFunctionTypeString(type: retType as! FunctionTypeNode)
                }
                
                let pars:String = createFunctionParameters(pars: function.pars)
                
                var declaredFunction:String = type+" "+identifier
                declaredFunction.append("("+pars+")")
                
                
                declaredFunctions.append(declaredFunction)
                
                // type navn ( pars ) block
                let funcDecl:String = "\n"+type+" "+identifier+"("+pars+")"+createBlock(block: block)
                ret += funcDecl
            }
            
            
            return ret
        }
    }
    
    // Creates a generic function
    internal func createGenericFunction(function: FunctionNode) -> String {
        guard let retType = function.retType,
            let identifier = function.identifier,
            let block = function.block else { return "" }
        
        // Find number of generics
        var vecFunc = ""
        var foundGenericNames:[String] = []
        for par in function.pars {
            if par.type is NormalTypeNode {
                guard let type = par.type as? NormalTypeNode, let clearType = type.clearType else { continue }
                
                if type.generic {
                    if !foundGenericNames.contains(clearType) {
                        foundGenericNames.append(clearType)
                    }
                }
            }
        }
        
        // Create typenames
        vecFunc += "template<"
        for n in 0 ..< foundGenericNames.count {
            vecFunc += "typename "+foundGenericNames[n]
            
            if n != foundGenericNames.count-1 {
                vecFunc += ", "
            }
        }
        vecFunc += ">\n"
        
        // Return type
        vecFunc += createTypeString(type: retType as! NormalTypeNode)
        
        vecFunc += " "+identifier
        
        // Parameters
        var vecPars = "("
        for n in 0 ..< function.pars.count {
            let par = function.pars[n]
            guard let pname = par.name else { continue }
            
            if par.type is NormalTypeNode {
                guard let ptype = par.type as? NormalTypeNode else { continue }
                
                vecPars += createTypeString(type: ptype)
                vecPars += " "+pname
            }
            else { // Function parameter
                guard let ptype = par.type as? FunctionTypeNode else { continue }
                
                let typeString = createFunctionTypeString(type: ptype)
                vecPars += typeString+" "+pname
            }
            
            if n != function.pars.count-1 {
                vecPars += ", "
            }
        }
        vecPars += ")"
        vecFunc += vecPars
        declaredFunctions.append(vecFunc)
        
        vecFunc += createBlock(block: block)
        
        return vecFunc
    }

    // Creates string with function parameters - (T1 n1, T2 n2 ... )
    internal func createFunctionParameters(pars: [ParameterNode]) -> String {
        var str = ""
        
        for n in 0 ..< pars.count {
            let par = pars[n]
                
            guard let tmpType = par.type, let name = par.name else { continue }
            
            if tmpType is NormalTypeNode { // Normal type, just 'Type Name'
                
                if !par.variadic {
                    str += createTypeString(type: tmpType as! NormalTypeNode)+" "+name
                }
                else { // Variadic
                    let fix = (tmpType as! NormalTypeNode).copy() as! NormalTypeNode
                    fix.numNested = 1
                    
                    str += createTypeString(type: fix)+" "+name
                }
            }
            else if tmpType is FunctionTypeNode { // Function type, 'Type Name (Parameters)'
                
                let typeString = createFunctionTypeString(type: tmpType as! FunctionTypeNode)
                
                if !par.variadic {
                    str += typeString+" "+name
                }
                else {
                    str += "std::vector<"+typeString+"> "+name
                }
            }
            
            if n != pars.count-1 {
                str += ", "
            }
        }
        
        return str
    }
    
    
    // MARK: Block
    // Creates block - { [expr] }
    internal func createBlock(block: BlockNode) -> String {
        
        var str = "{\n"
        
        // Save arguments!
        if doingMainBlock {
            str += "for(int n = 0; n < argc; n++) { std::string argS(argv[n]); std::vector<char> argV(argS.begin(), argS.end()); internal_arguments.push_back(argV); }\n"
            doingMainBlock = false
        }
        
        // Create expressions in block
        for expr in block.expressions {
            
            // Variadic parameters -> [lists]
            fixVariadicFunctions(expr: expr)
            
            // Do we need to declare something before the expression? (Function call parameters are declared before the call)
            str += createFunctionCallParameterDeclarations(expr: expr)
            str += createExpressionArrayLiterals(expr: expr)
            
            str += createExpression(expr: expr)
        }
        
        str += "\n}\n"
        
        return str
    }
    
    
    // MARK: Function calls
    // Creates a function call - name "(" [expr] ")"
    internal func createFunctionCall(call: FunctionCallNode) -> String {
        guard let identifier = call.identifier else { return "" }
        
        var parString = ""
        
        for n in 0 ..< call.parameters.count {
            let par = call.parameters[n]
            let expr = createExpression(expr: par)
            parString += expr
            
            if n != call.parameters.count-1 {
                parString += ", "
            }
        }
        
        let str = identifier+"("+parString+")"
        return str
    }
    
    // Creates a function type definition based on a FunctionNode: 'define test: Int a, Int b -> Int' becomes std::function<int(int, int)>
    func createFunctionTypeDefinition(function: FunctionNode) -> String {
        guard let retType = function.retType else { return "" }
        
        var str = "std::function<"
        
        // Ret
        if retType is NormalTypeNode {
            str += createTypeString(type: retType as! NormalTypeNode)
        }
        else {
            str += createFunctionTypeString(type: retType as! FunctionTypeNode)
        }
        
        str += "("
        
        // Pars
        for n in 0 ..< function.pars.count {
            let p = function.pars[n]
        
            guard let type = p.type else { continue }
            if type is NormalTypeNode {
                str += createTypeString(type: type as! NormalTypeNode)
            }
            else if type is FunctionTypeNode {
                str += createFunctionTypeString(type: type as! FunctionTypeNode)
            }
            
            if n != function.pars.count-1 {
                str += ", "
            }
        }
        
        str += ")>"
        
        return str
    }
    
    
    // MARK: Types (Normal and function types)
    // Creates a string from a normal type. Int becomes int, String becomse std::vector<char> and so on.
    internal func createTypeString(type: NormalTypeNode) -> String {
        guard let clearType = type.clearType, let nested = type.numNested else { return "" }

        if nested == 0 {
            if let converted = typeConversions[clearType] {
                return converted
            }
            
            if ParserTables.shared.types.contains(clearType) {
                return "t_"+ParserTables.shared.createRename(forIdentifier: clearType)+" *"
            }
            
            return clearType // Må være objekt
        }
        
        var str = ""//"const "
        
        for i in 0 ..< nested {
            str += "std::vector<"
            
            if i == nested-1 {
                if let converted = typeConversions[clearType] {
                    str += converted
                }
                else if ParserTables.shared.types.contains(clearType) {
                    str += "t_"+ParserTables.shared.createRename(forIdentifier: clearType)+" *"
                }
                else {
                    str += clearType
                }
            }
        }
        
        for _ in 0 ..< nested {
            str += ">"
        }
        
        return str
    }
    
    
    // Creates a function type string (Other syntax than normal types)
    internal func createFunctionTypeString(type: FunctionTypeNode) -> String {
        
        guard let ret = type.ret else { return "" }
        var str = "std::function<"
        
        if ret is NormalTypeNode {
            str += createTypeString(type: ret as! NormalTypeNode)
        }
        else if ret is FunctionTypeNode {
            str += createFunctionTypeString(type: ret as! FunctionTypeNode)
        }
        
        str += "("
        
        for n in 0 ..< type.inputs.count {
            let t = type.inputs[n]
            
            if t is NormalTypeNode {
                str += createTypeString(type: t as! NormalTypeNode)
            }
            else if t is FunctionTypeNode {
                str += createFunctionTypeString(type: t as! FunctionTypeNode)
            }
            
            if n != type.inputs.count-1 {
                str += ", "
            }
        }
        
        str += ")"
        
        str += ">"
        
        return str
    }
    
    
    // MARK: Literals
    // Creates a string literal (Convert to vector, basically)
    func createStringLiteral(string: StringLiteralNode) -> String {
        guard let litContent = string.content else { return "" }
        var str = "{"

        var n = 0
        while n < litContent.characters.count {
            let c = litContent.charAt(index: n)
            
            // Escaping something?
            if c == "\\" {
                let nc = litContent.charAt(index: n+1)
                
                if nc == "\"" { // Quote, no need to escape
                    str += "'"+String(nc)+"'"
                }
                else { // Something else, like \n, \t and so.
                    str += "'"+String(c)+String(nc)+"'"
                }
                
                n += 1
            }
            else if c == "'" { // Escape as we convert to char, so escaping single quote is necessary.
                str += "'\\''"
            }
            else { // Regular char
                str += "'"+String(c)+"'"
            }
            
            if n != litContent.characters.count-1 {
                str += ", "
            }
            
            n += 1
        }
        
        str += "}"
        
        return str
    }
    
    // Laver array literal indhold (expr, expr ...)
    func createArrayLiteral(lit: ArrayLiteralNode) -> String {
        
        var str = "{"
        
        for n in 0 ..< lit.contents.count {
            let expr = lit.contents[n]
            str += createExpression(expr: expr)
            
            if n != lit.contents.count-1 {
                str += ", "
            }
        }
        
        str += "}"
        
        return str
    }
    
    // MARK: Expressions (1+2 (1+2) (true AND false) ... )
    // Laver par expression - "(" expr ")"
    internal func createParenthesisExpression(expr: ParenthesesExpression) -> String {
        var str = "("
        str += createExpression(expr: expr.expression!)
        str += ")"
        return str
    }
    
    // Laver expression node  -  expr OP expr
    internal func createExpressionNode(expr: ExpressionNode) -> String {
        guard let op = expr.op, let ops = op.op, let lop = expr.loperand, let rop = expr.roperand else { return "" }
        
        var str = ""
        str += createExpression(expr: lop)
        str += " "
        
        // Erstat operators hvis nødvendigt
        if let replace = opConversions[ops] {
            str += replace
        }
        else {
            str += ops
        }
        
        str += " "
        str += createExpression(expr: rop)
        
        return str
    }

    
    // MARK: Create Expression Main
    // Creates an expression (Covers all expression types)
    internal func createExpression(expr: Node) -> String {
        if expr is IfElseNode {
            return createIfElseNode(ifElse: (expr as! IfElseNode))
        }
        else if expr is LetNode {
            return createLetNode(letN: (expr as! LetNode))
        }
        else if expr is SwitchNode {
            return createSwitchNode(node: (expr as! SwitchNode))
        }
        else if expr is LambdaNode {
            return createLambdaNode(node: (expr as! LambdaNode))
        }
        else if expr is LetVariableNode {
            guard let expr = expr as? LetVariableNode else { return "" }
            
            return createVariableDeclaration(identifier: expr.name!, type: expr.type!, expr: expr.value!)
        }
        var retString = ""
        
        let shouldRet = shouldReturn(node: expr)
        if shouldRet {
            retString = "return "
        }
        
        switch expr {
        case is ExpressionNode:
            retString += createExpressionNode(expr: (expr as! ExpressionNode))
            break
            
        // Literals
        case is NumberLiteralNode:
            let exp = (expr as! NumberLiteralNode)
            if exp.floatValue != nil {
                retString += String(exp.floatValue!)
            }
            else if exp.intValue != nil {
                retString += String(exp.intValue!)
            }
            break
            
        case is VariableNode:
            if let id = (expr as! VariableNode).identifier {
                if id == "null" {
                    retString += "NULL"
                }
                else {
                    retString += id
                }
            }
            break
            
        case is BooleanLiteralNode:
            retString += (expr as! BooleanLiteralNode).value
            break
            
        case is FunctionCallNode:
            retString += createFunctionCall(call: (expr as! FunctionCallNode))
            break
            
        case is ParenthesesExpression:
            retString += createParenthesisExpression(expr: (expr as! ParenthesesExpression))
            break
            
        case is NegateExpression:
            guard let nested = (expr as! NegateExpression).expression else { break }
            retString += "!"+createExpression(expr: nested)
            break
            
        case is MinusExpression:
            guard let nested = (expr as! MinusExpression).expression else { break }
            retString += "-"+createExpression(expr: nested)
            break
            
        case is StringLiteralNode:
            retString += createStringLiteral(string: (expr as! StringLiteralNode))
            break
            
        case is ArrayLiteralNode:
            retString += createArrayLiteral(lit: (expr as! ArrayLiteralNode))
            break
            
        case is CharLiteralNode:
            retString += "'"+(expr as! CharLiteralNode).content!+"'"
            break
            
        default:
            retString += ""
            break
        }
        
        if shouldRet { // End of expression
            retString += ";\n"
        }
        
        if expr is FunctionCallNode { // Side conditions should be ended too.
            let fc = expr as! FunctionCallNode
            guard let name = fc.identifier else { return retString }
            if ParserTables.shared.sideConditionFunctions.contains(name) {
                retString += ";\n"
            }
        }
        
        return retString
    }
    
    
    // MARK: Special expressions (let, switch, if-else)
    // Creates switch (if(){} else if(){} and so on)
    
    // MARK: Switch
    func createSwitchNode(node: SwitchNode) -> String {
        
        // SPecial case
        if let parent = node.parent {
            if parent is LetVariableNode {
                return createLetSwitchNode(node: node)
            }
        }
        
        var str = ""
        
        for n in 0 ..< node.cases.count {
            let c = node.cases[n]
            
            if !(c.expr is ElseNode) { // Case node
                
                if n != 0 {
                    str += " else"
                }
                
                str += " if("
                str += createExpression(expr: c.expr!)
                str += ")"
                str += createBlock(block: c.block!)
            }
            else { // Else node
                str += " else "
                str += createBlock(block: c.block!)
            }
        }
        
        return str
    }
    
    internal func createLetSwitchNode(node: SwitchNode) -> String {
        var str = "[=]"
        
        let newBlock = BlockNode(exprs: [node])
        str += createBlock(block: newBlock)
        str += "()"
        
        return str
    }

    // MARK: If-Else
    // Laver if-else - "if" expr block block
    internal func createIfElseNode(ifElse: IfElseNode) -> String {
        guard let iblock = ifElse.ifBlock, let eblock = ifElse.elseBlock, let cond = ifElse.condition, let parent = ifElse.parent else { return "" }
        
        // Special case (if used in 'let' definition)
        if parent is LetVariableNode {
            return createLetIfElseNode(ifElse: ifElse)
        }
        
        // Normal if
        var str = ""
        
        str += "if("
        str += createExpression(expr: cond)
        str += ")\n"
        str += createBlock(block: iblock)
        str += "else "
        str += createBlock(block: eblock)
        
        return str
    }
    
    // Creates a lambdanode that handles the if statement
    internal func createLetIfElseNode(ifElse: IfElseNode) -> String {
        guard let _ = ifElse.ifBlock, let _ = ifElse.elseBlock, let _ = ifElse.condition, let _ = ifElse.parent else { return "" }
        
        var str = "[=]"
        
        let newBlock = BlockNode(exprs: [ifElse])
        str += createBlock(block: newBlock)
        str += "()"

        return str
    }
    
    // MARK: Let
    // Laver let - "let" [Type name "=" expr] block
    internal func createLetNode(letN: LetNode) -> String {
        guard let block = letN.block else { return "" }

        // Lav funktionens indhold
        var str = ""
        
        for v in letN.vars {
            guard let ttype = v.type, let name = v.name, let expr = v.value else { continue }
            fixVariadicFunctions(expr: expr)
            str += createFunctionCallParameterDeclarations(expr: expr)
            str += createVariableDeclaration(identifier: name, type: ttype, expr: expr)
        }
        
        str += createBlock(block: block)
        
        return str
    }
    
    // Creates a declaration. For example: int i = 1;
    internal func createVariableDeclaration(identifier: String, type: TypeNode, expr: Node) -> String {
        var str = ""
        
        var typeString = ""
        if type is NormalTypeNode {
            typeString = createTypeString(type: type as! NormalTypeNode)
            
        }
        else if type is FunctionTypeNode {
            typeString = createFunctionTypeString(type: type as! FunctionTypeNode)
        }
        
        str += typeString+" "+identifier
        
        // Types require some kind of initialization
        if type is NormalTypeNode && TreeHelper.isObjectType(type: type as! NormalTypeNode) {
            str += " = {}"
        }
        
        str += ";\n"
        str += identifier+" = "
        str += createExpression(expr: expr)
        
        str += ";\n"
        return str
    }
    
    // MARK: Lambda
    // Creates a lambda node
    internal func createLambdaNode(node: LambdaNode) -> String {
        guard let block = node.block else { return "" }
        
        var str = "[=]"
        
        let parString:String = createFunctionParameters(pars: node.pars)

        str += "("+parString+")"
        
        // Lambda return value
        if let retType = node.retType {
            if retType is NormalTypeNode {
                str += " -> "+createTypeString(type: retType as! NormalTypeNode)
            }
        }
        
        str += createBlock(block: block)
        
        return str
    }
    
    
    // MARK: Helpers
    // Should this expression be returned? (No for example: 'if 1 == 2', because we don't want 'if return 1 == 2'
    internal func shouldReturn(node: Node) -> Bool {
        
        var tmpNode:Node = node
        while tmpNode.parent != nil {
            let par = tmpNode.parent!
            
            if par is BlockNode {
                if node is FunctionCallNode { // Side condition?
                    let tmpNode = node as! FunctionCallNode
                    guard let name = tmpNode.identifier else { return true }
                    
                    if ParserTables.shared.sideConditionFunctions.contains(name) {
                        return false
                    }
                }
                
                return true
            }
            else if par is IfElseNode {
                return false
            }
            else if par is LetNode {
                return false
            }
            else if par is ParameterNode {
                return false
            }
            else if par is ExpressionNode {
                return false
            }
            else if par is FunctionCallNode {
                return false
            }
            else if par is ParenthesesExpression {
                return false
            }
            else if par is SwitchNode {
                return false
            }
            else if par is ArrayLiteralNode {
                return false
            }
            else if par is NegateExpression {
                return false
            }
            else if par is MinusExpression {
                return false
            }
            else {
                tmpNode = par
            }
        }
        
        return false
    }
    
    // Attempt to determine which version of a function is being called (For overloading purposes)
    internal func determineFunctionNodeForCall(call: FunctionCallNode) -> FunctionNode? {
        guard let identifier = call.identifier else { return nil }
        guard let declList = ParserTables.shared.functionDeclarations[identifier] else { return nil }
        
        // Nothing or exactly one found
        if declList.count == 0 {
            return nil
        }
        if declList.count == 1 {
            return declList[0]
        }
        
        // We have something overloaded
        var highestParCount = 0
        for n in 0 ..< declList.count {
            let decl = declList[n]
            
            if highestParCount > decl.pars.count {
                highestParCount = decl.pars.count
            }
            
            // If formal and actual parameter count matches, we can assume this is the correct one (C++ compiler will figure it out otherwise.)
            if decl.pars.count == call.parameters.count {
                return decl
            }
        }
        
        // Still not found, meaning that it's probably a variadic call
        if call.parameters.count > highestParCount {
            // Check for a function which contains a variadic parameter
            for decl in declList {
                for p in decl.pars {
                    if p.variadic {
                        return decl
                    }
                }
            }
        }
        
        // Don't know what it is.
        print("Funktionen \(identifier) er stadig ikke fundet.. Shit.")
        
        
        return nil
    }
}
