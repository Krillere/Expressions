//
//  CodeGenerator.swift
//  Parser
//
//  Created by Christian Lundtofte on 28/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class CodeGenerator {
    private var internalCode:String = ""
    private var program:ProgramNode?

    // Prototyper
    private var declaredFunctions:[String] = []
    
    // Ting der skal ændres direkte
    private var typeConversions:[String: String] = ["Int":"int", "Char":"char", "Float":"float", "String":"std::string", "Bool":"bool", "Generic":"Generic"]
    private var opConversions:[String: String] = ["AND":"&&", "OR":"||"]
    
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    // Laver og printer kode
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
    
    private func emit(_ str: String) {
        internalCode += str
    }
    
    // Generer typer
    private func createObjectType(objType: ObjectTypeNode) -> String {
        guard let name = objType.name else { return "" }
        
        var ret = ""
        
        // Type declaration
        var typeDecl = "struct t_"+name+" {\n"
        
        for v in objType.variables {
            guard let ttype = v.type, let vname = v.identifier else { continue }
            var type = ""
            if ttype is NormalTypeNode {
                type = createTypeString(type: ttype as! NormalTypeNode)
            }
            typeDecl += " "+type+" "+vname+";\n"
        }
        
        typeDecl += "};"
        ret += typeDecl
        
        declaredFunctions.append("struct t_"+name)
        
        // Initialization function
        
        // Function definition
        var typeInit = "t_"+name+" "+name+"("
        for n in 0 ..< objType.variables.count {
            let v = objType.variables[n]
            guard let ttype = v.type, let vname = v.identifier else { continue }
            
            var type = ""
            if ttype is NormalTypeNode {
                type = createTypeString(type: ttype as! NormalTypeNode)
            }
            typeInit += type+" "+vname
            
            if n != objType.variables.count-1 {
                typeInit += ", "
            }
        }
        typeInit += ")"
        
        declaredFunctions.append(typeInit)
        
        // Function block
        typeInit += " {\n"
        
        typeInit += "t_"+name+" t_tmp;"
        for n in 0 ..< objType.variables.count {
            let v = objType.variables[n]
            guard let vname = v.identifier else { continue }
            
            typeInit += "t_tmp."+vname+" = "+vname+";\n"
        }
        
        typeInit += "return t_tmp;"
        
        typeInit += "}\n"
        
         ret += "\n"+typeInit
        
        return ret
    }

    // Generer funktioner
    private func createFunction(function: FunctionNode) -> String {
        guard let retType = function.retType,
            let identifier = function.identifier,
            let block = function.block else { return "" }
        
        var ret = ""
        
        var type = ""
        if retType is NormalTypeNode {
            type = createTypeString(type: retType as! NormalTypeNode)
        }
        
        let pars:String = createFunctionParameters(pars: function.pars)
        
        var declaredFunction:String = type+" "+identifier
        declaredFunction.append("("+pars+")")
        declaredFunctions.append(declaredFunction)
        
        // type navn ( pars ) block
        let funcDecl:String = "\n"+type+" "+identifier+"("+pars+")"+createBlock(block: block)
        ret += funcDecl
        
        return ret
    }
    
    
    // Laver string med funktionsparametre - (T1 n1, T2 n2 ... )
    private func createFunctionParameters(pars: [ParameterNode]) -> String {
        var str = ""
        
        for n in 0 ..< pars.count {
            let par = pars[n]
                
            guard let tmpType = par.type, let name = par.name else { continue }
            
            if tmpType is NormalTypeNode { // Normal type, just 'Type Name'
                let type = createTypeString(type: tmpType as! NormalTypeNode)
                str += type+" "+name

            }
            else if tmpType is FunctionTypeNode { // Function type, 'Type Name (Parameters)'
                let retType = createFunctionTypeString(type: tmpType as! FunctionTypeNode, context: .preName)
                let inp = createFunctionTypeString(type: tmpType as! FunctionTypeNode, context: .postName)
                str += retType+" "+name+inp
            }
            
            if n != pars.count-1 {
                str += ", "
            }
        }
        
        return str
    }
    
    
    // Creates block - { expr }
    private func createBlock(block: BlockNode) -> String {
        
        var str = "{\n"
        str += createExpression(expr: block.expression!)
        str += "\n}\n"
        
        return str
    }
    
    // Creates a string from a normal type. Int becomes int, String becomse std::string and so on.
    private func createTypeString(type: NormalTypeNode) -> String {
        guard let clearType = type.clearType else { return "" }
        
        if type.numNested == 0 {
            if let converted = typeConversions[clearType] {
                return converted
            }
            
            if ParserTables.types.contains(clearType) {
                return "t_"+clearType
            }
            
            return clearType // Må være objekt
        }
        
        var str = ""
        
        for i in 0 ..< type.numNested! {
            str += "std::vector<"
            
            if i == type.numNested!-1 {
                if let converted = typeConversions[clearType] {
                    str += converted
                }
                else if ParserTables.types.contains(clearType) {
                    str += "t_"+clearType
                }
                else {
                    str += clearType
                }
            }
        }
        
        for _ in 0 ..< type.numNested! {
            str += ">"
        }
        
        return str
    }
    
    
    // Are we before the name or after? (Important for function types)
    private enum FunctionTypeContext {
        case preName
        case postName
    }
    private func createFunctionTypeString(type: FunctionTypeNode, context: FunctionTypeContext) -> String {
        
        if context == .preName {
            return createTypeString(type: type.ret as! NormalTypeNode)
        }
        else if context == .postName {
            var str = "("
            
            for n in 0 ..< type.inputs.count {
                let t = type.inputs[n]
                str += createTypeString(type: t as! NormalTypeNode)
                
                if n != type.inputs.count-1 {
                    str += ", "
                }
            }
            
            str += ")"
            
            return str
        }

        return ""
    }
    
    // Burde vi returnere denne expression? (Nej hvis f.eks. if(1 == 2), skal jo ikke være if(return 1 == 2))
    private func shouldReturn(node: Node) -> Bool {
        
        var tmpNode:Node = node
        while tmpNode.parent != nil {
            let par = tmpNode.parent!
            
            if par is BlockNode {
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
            else {
                tmpNode = par
            }
        }
        
        return false
    }
    
    // Laver expression (Alle typer)
    private func createExpression(expr: Node) -> String {
        if expr is IfElseNode {
            return createIfElseNode(ifElse: (expr as! IfElseNode))
        }
        else if expr is LetNode {
            return createLetNode(letN: (expr as! LetNode))
        }
        else if expr is SwitchNode {
            return createSwitchNode(node: (expr as! SwitchNode))
        }
        
        var retString = ""
        
        let shouldRet = shouldReturn(node: expr)
        if shouldRet {
            retString = "return "
        }
        else {
            //print("Returnerer IKKE: \(expr)")
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
                retString += id
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
            
        case is StringLiteralNode:
            retString += "\""+(expr as! StringLiteralNode).content!+"\""
        break
            
        case is ArrayLiteralNode:
            retString += createArrayLiteral(lit: (expr as! ArrayLiteralNode))
        break
            
        default:
            retString += ""
            break
        }
        
        if shouldRet {
            retString += ";"
        }
        
        return retString
    }
    
    // Laver array literal indhold (expr, expr ...)
    func createArrayLiteral(lit: ArrayLiteralNode) -> String {
        
        var str = ""
        
        str += "{"
        
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
    
    // Laver par expression - "(" expr ")"
    private func createParenthesisExpression(expr: ParenthesesExpression) -> String {
        var str = "("
        str += createExpression(expr: expr.expression!)
        str += ")"
        return str
    }
    
    // Laver switch
    func createSwitchNode(node: SwitchNode) -> String {
        var str = ""
        
        for n in 0 ..< node.cases.count {
            let c = node.cases[n]
            
            if !(c.expr is ElseNode) { // Almindelig
                
                if n != 0 {
                    str += " else"
                }
                
                str += " if("
                str += createExpression(expr: c.expr!)
                str += ")"
                str += createBlock(block: c.block!)
            }
            else { // Sjovt nok, else!
                str += " else "
                str += createBlock(block: c.block!)
            }
        }
        
        return str
    }
    
    // Laver expression node  -  expr OP expr
    private func createExpressionNode(expr: ExpressionNode) -> String {
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
    
    // Laver funktionskald - name "(" [expr] ")"
    private func createFunctionCall(call: FunctionCallNode) -> String {
        guard let identifer = call.identifier else { return "" }
        var str = ""
        
        str += identifer
        str += "("
        
        for n in 0 ..< call.parameters.count {
            let par = call.parameters[n]
            str += createExpression(expr: par)
            
            if n != call.parameters.count-1 {
                str += ", "
            }
        }
        
        str += ")"
        
        return str
    }
    
    // Laver if-else - "if" expr block block
    private func createIfElseNode(ifElse: IfElseNode) -> String {
        guard let iblock = ifElse.ifBlock, let eblock = ifElse.elseBlock, let cond = ifElse.condition else { return "" }
        var str = ""
        
        str += "if("
        str += createExpression(expr: cond)
        str += ")\n"
        str += createBlock(block: iblock)
        str += "else "
        str += createBlock(block: eblock)
        
        return str
    }
    
    // Laver let - "let" [Type name "=" expr] block
    private func createLetNode(letN: LetNode) -> String {
        guard let block = letN.block, let bexpr = block.expression else { return "" }
        

        // Lav funktionens indhold
        var str = "{"
        
        for v in letN.vars {
            guard let ttype = v.type, let name = v.name, let expr = v.value else { continue }
            
            var type = ""
            if ttype is NormalTypeNode {
                type = createTypeString(type: ttype as! NormalTypeNode)
            }
            
            str += type+" "+name+" = "
            str += createExpression(expr: expr)
            str += ";\n"
        }
        
        str += createExpression(expr: bexpr)
        str += "}"
        
        return str
    }
}
