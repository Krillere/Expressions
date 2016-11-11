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
    
    // Direct conversions (Types and operators)
    private var typeConversions:[String: String] = ["Int":"int", "Char":"char", "Float":"float", "String":"std::vector<char>", "Bool":"bool", "Generic":"T"]
    private var opConversions:[String: String] = ["AND":"&&", "OR":"||"]
    
    
    init(program: ProgramNode) {
        self.program = program
    }
    
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
    
    private func emit(_ str: String) {
        internalCode += str
    }
    
    // Generates a type declaration
    private func createObjectType(objType: ObjectTypeNode) -> String {
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
                
                let retType = createFunctionTypeString(type: ttype, context: .preName)
                let inp = createFunctionTypeString(type: ttype, context: .postName)
                typeDecl += retType+" (*"+vname+")"+inp+";\n"
            }
            
            
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
            
            if ttype is NormalTypeNode {
                guard let ttype = ttype as? NormalTypeNode else { return "" }
                let type = createTypeString(type: ttype)
                typeInit += type+" "+vname
            }
            else if ttype is FunctionTypeNode {
                guard let ttype = ttype as? FunctionTypeNode else { return "" }
                let retType = createFunctionTypeString(type: ttype, context: .preName)
                let inp = createFunctionTypeString(type: ttype, context: .postName)
                typeInit += retType+" "+vname+inp
            }
            
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

    // Generates a function declaration
    private func createFunction(function: FunctionNode) -> String {
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
                
                let funcDecl:String = "\n"+declaredFunction+createBlock(block: block)
                ret += funcDecl
            }
            else {
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
            }
            
            
            return ret
        }
    }
    
    // Creates a generic function
    private func createGenericFunction(function: FunctionNode) -> String {
        guard let retType = function.retType else { return "" }
        
        var retGen = false
        if retType is NormalTypeNode {
            guard let retType = retType as? NormalTypeNode else { return "" }
            retGen = retType.generic
        }
        
        var str = ""

        // Vector function
        str += createGenericVectorFunction(function: function, retGen: retGen)
        
        return str
    }
    
    private func createGenericVectorFunction(function: FunctionNode, retGen: Bool) -> String {
        guard let retType = function.retType,
            let identifier = function.identifier,
            let block = function.block else { return "" }
        
        var vecFunc = "template<typename T>\n"
        
        // Return type
        if retGen {
            let tmpType = (retType as! NormalTypeNode).copy() as! NormalTypeNode
            tmpType.clearType = "T"
            
            vecFunc += createTypeString(type: tmpType)
        }
        else {
            vecFunc += createTypeString(type: retType as! NormalTypeNode)
        }
        
        vecFunc += " "+identifier
        
        // Parameters
        var vecPars = "("
        for n in 0 ..< function.pars.count {
            let par = function.pars[n]
            
            guard let pname = par.name, let ptype = par.type as? NormalTypeNode else { continue }
            if ptype.generic {
                let tmpType = ptype.copy() as! NormalTypeNode
                tmpType.clearType = "T"
                
                vecPars += createTypeString(type: tmpType)
            }
            else {
                vecPars += createTypeString(type: ptype)
            }
            
            vecPars += " "+pname
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
    
    
    // Creates block - { [expr] }
    private func createBlock(block: BlockNode) -> String {
        
        var str = "{\n"
        
        // Create expressions in block
        for expr in block.expressions {
            
            // Do we need to declare something before the expression? (Function call parameters are declared before the call)
            str += createFunctionCallParameterDeclarations(expr: expr)
            
            // Create the expression itself
            str += createExpression(expr: expr)
        }
        
        str += "\n}\n"
        
        return str
    }
    
    // Create function call parameters as variables in the start of the block
    private func createFunctionCallParameterDeclarations(expr: Node) -> String {
        if expr is FunctionCallNode { // Found function call, declare parameters and exchange them for the variablename
            guard let fc = expr as? FunctionCallNode else { return "" }
            print("Fundet function call: \(fc.identifier!)")
            
            for n in 0 ..< fc.parameters.count {
                let par = fc.parameters[n]
            
                if par is ArrayLiteralNode {
                    guard let par = par as? ArrayLiteralNode else { return "" }
                    
                    // Create a new name and refer it to itself in translation
                    let newName = ParserTables.shared.generateNewVariableName()
                    ParserTables.shared.nameTranslation[newName] = newName
                    
                    // Replace literal with reference to variable
                    let replacementNode = VariableNode(identifier: newName)
                    fc.parameters[n] = replacementNode
                    
                    let type = guessType(node: par)
                    let str = "std::vector<"+type+"> "+newName+" = "+createArrayLiteral(lit: par)+";"
                    return str
                }
                else if par is StringLiteralNode { // String literal used as parameter
                    guard let par = par as? StringLiteralNode else { return "" }
                    
                    // Create a new name and refer it to itself in translation
                    let newName = ParserTables.shared.generateNewVariableName()
                    ParserTables.shared.nameTranslation[newName] = newName
                    
                    // Replace the literal with a reference to the variable
                    let replacementNode = VariableNode(identifier: newName)
                    fc.parameters[n] = replacementNode
                    
                    let str = "std::vector<char> "+newName+" = "+createStringLiteral(string: par)+";"
                    return str
                }
                else if par is FunctionCallNode {
                    return createFunctionCallParameterDeclarations(expr: par)
                }
            }
        }
        else if expr is ParenthesesExpression { // Possibly containing a function call
            if let tmp = (expr as! ParenthesesExpression).expression {
                return createFunctionCallParameterDeclarations(expr: tmp)
            }
        }
        else if expr is ExpressionNode { // expr OP expr, possible that expr is a function call
            guard let expr = expr as? ExpressionNode else { return "" }
            if let exp1 = expr.loperand, let exp2 = expr.roperand {
                var str = ""
                
                str += createFunctionCallParameterDeclarations(expr: exp1)
                str += createFunctionCallParameterDeclarations(expr: exp2)
                
                return str
            }
        }
        
        return ""
    }
    
    // Creates a string from a normal type. Int becomes int, String becomse std::vector<char> and so on.
    private func createTypeString(type: NormalTypeNode) -> String {
        guard let clearType = type.clearType, let nested = type.numNested else { return "" }

        if nested == 0 {
            if let converted = typeConversions[clearType] {
                return converted
            }
            
            if ParserTables.shared.types.contains(clearType) {
                return "t_"+ParserTables.shared.createRename(forIdentifier: clearType)
            }
            
            return clearType // Må være objekt
        }
        
        var str = ""
        
        for i in 0 ..< nested {
            str += "std::vector<"
            
            if i == nested-1 {
                if let converted = typeConversions[clearType] {
                    str += converted
                }
                else if ParserTables.shared.types.contains(clearType) {
                    str += "t_"+ParserTables.shared.createRename(forIdentifier: clearType)
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
    
    
    // Are we before the name or after? (Important for function types due to C++ syntax, as we need: RetType Name (Pars)   )
    private enum FunctionTypeContext {
        case preName
        case postName
    }
    
    // Creates a function type string (Other syntax than nnormal types)
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
    
    
    // Creates an expression (Covers all expression types)
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
            retString += createStringLiteral(string: (expr as! StringLiteralNode))
        break
            
        case is ArrayLiteralNode:
            retString += createArrayLiteral(lit: (expr as! ArrayLiteralNode))
        break
            
        case is CharLiteralNode:
            retString += "'"+(expr as! CharLiteralNode).content!+"'"
        break
            
        case is PropertyValueNode:
            guard let node = expr as? PropertyValueNode, let name = node.name else { break }
            
            if node.call == nil {
                guard let property = node.property else { break }
                retString += ParserTables.shared.createRename(forIdentifier: name)+"."+property
            }
            else {
                retString += ParserTables.shared.createRename(forIdentifier: name)+"."+createFunctionCall(call: node.call!)
            }
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
    
    // Creates a string literal (Convert to vector, basically)
    func createStringLiteral(string: StringLiteralNode) -> String {
        guard let litContent = string.content else { return "" }
        var str = "{"

        var n = 0
        for c in litContent.characters {
            str += "'"+String(c)+"'"
            
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

        var str = identifier
        str += "("
        str += parString
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
        guard let block = letN.block else { return "" }
        

        // Lav funktionens indhold
        var str = "{"
        
        for v in letN.vars {
            guard let ttype = v.type, let name = v.name, let expr = v.value else { continue }
            
            // Normal type
            if ttype is NormalTypeNode {
                guard let ttype = ttype as? NormalTypeNode else { return "" }
                
                let type = createTypeString(type: ttype)
                str += type+" "+name+" = "
                str += createExpression(expr: expr)
            }
            else if ttype is FunctionTypeNode { // Function type
                guard let ttype = ttype as? FunctionTypeNode else { return "" }
                
                let retType = createFunctionTypeString(type: ttype, context: .preName)
                let inp = createFunctionTypeString(type: ttype, context: .postName)
                str += retType+" (*"+name+")"+inp+" = "+createExpression(expr: expr)
            }
            
            str += ";\n"
        }
        
        for bexpr in block.expressions {
            str += createExpression(expr: bexpr)
        }
        str += "}"
        
        return str
    }
    
    
    // MARK: Helpers
    // Burde vi returnere denne expression? (Nej hvis f.eks. if(1 == 2), skal jo ikke være if(return 1 == 2))
    private func shouldReturn(node: Node) -> Bool {
        
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
            else {
                tmpNode = par
            }
        }
        
        return false
    }
    
    // Determine (gues..) the type of a literal (Array is guessing, rest is pretty straight forward) (Guess is fine. C++ compiler catches mistakes..)
    private func guessType(node: Node) -> String {

        if node is ArrayLiteralNode {
            guard let node = node as? ArrayLiteralNode else { return "" }
            if node.contents.count < 1 {
                return "FUCK"
            }
            
            let fnode = node.contents[0]
            if fnode is CharLiteralNode {
                return "char"
            }
            else if fnode is NumberLiteralNode {
                if let fnode = fnode as? NumberLiteralNode {
                    if fnode.floatValue != nil {
                        return "float"
                    }
                    else if fnode.intValue != nil {
                        return "int"
                    }
                }
            }
            else if fnode is ArrayLiteralNode {
                let str = "std::vector<"+guessType(node: fnode)+">"
                return str
            }
            else if fnode is StringLiteralNode {
                return "std::vector<char>"
            }
        }
        else if node is NumberLiteralNode {
            if let node = node as? NumberLiteralNode {
                if node.floatValue != nil {
                    return "float"
                }
                else if node.intValue != nil {
                    return "int"
                }
            }
        }
        else if node is StringLiteralNode {
            return "std::vector<char>"
        }
        else if node is CharLiteralNode {
            return "char"
        }
        else if node is BooleanLiteralNode {
            return "bool"
        }
        
        return ""
    }
}
