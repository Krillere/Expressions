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
    
    private var curFunctionPars:String = ""
    private var curFunctionParsList:[ParameterNode] = []
    private var curFunctionRet:String = ""
    private var funcDecls:[String] = []
    
    private var typeConversions:[String: String] = ["Int":"int", "Char":"char", "Float":"float", "String":"std::string"]
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    func generate() {
        guard let program = self.program else { return }
        let functions = program.functions
        
        for function in functions {
            emitFunction(function: function)
        }
        
        
        // Imports og declarations og shitz
        var decls = "// Prototypes \n"
        for dec in funcDecls {
            decls += dec+";\n"
        }
        decls += "\n\n// Generated:\n"
        internalCode = decls+internalCode
        for f in afterFuncs {
            internalCode += "\n"+f+"\n"
        }
        print("Code:")
        print(internalCode)
    }
    
    private func emit(_ str: String) {
        internalCode += str
    }
    
    var letIndex:Int = 0
    var ifIndex:Int = 0
    var afterFuncs:[String] = []
    
    private func appendFuncAfter(appFunc: String) {
        self.afterFuncs.append(appFunc)
    }
    
    // Generer funktioner
    private func emitFunction(function: FunctionNode) {
        guard let retType = function.retType,
            let identifier = function.identifier,
            let type = typeConversions[retType],
            let block = function.block else { return }
        
        
        let pars = createFunctionParameters(pars: function.pars)
        self.curFunctionPars = pars
        self.curFunctionRet = type
        self.curFunctionParsList = function.pars
        
        funcDecls.append(type+" "+identifier+"("+pars+")")
        
        emit("\n"+type+" ") // int
        emit(identifier) // main
        emit("("+pars+")")
        emit(createFunctionBlock(block: block))
    }
    
    // Laver string med funktionsparametre (bruges senere)
    private func createFunctionParameters(pars: [ParameterNode]) -> String {
        var str = ""
        
        for n in 0 ..< pars.count {
            let par = pars[n]
            guard let tmpType = par.type, let type = typeConversions[tmpType], let name = par.name else { continue }
            str += type+" "+name
            
            if n != pars.count-1 {
                str += ", "
            }
        }
        
        return str
    }

    // Laver en blok
    private func createBlock(block: BlockNode) -> String {
        var str = "{"
        
        if let expr = block.expression {
            str += createExpression(expr: expr)
        }
        
        str += "}"
        return str
    }
    
    private func createFunctionBlock(block: BlockNode) -> String {
        
        var str = "{"
        str += " return "
        str += createExpression(expr: block.expression!)
        str += "; }"
        
        return str
    }
    
    private func createExpression(expr: Node) -> String {
        switch expr {
        case is IfElseNode:
            return createIfElseNode(ifElse: (expr as! IfElseNode))
            
        case is LetNode:
            return createLetNode(letN: (expr as! LetNode))
            
        case is ExpressionNode:
            return createExpressionNode(expr: (expr as! ExpressionNode))
            
        // Literals
        case is NumberLiteralNode:
            return String(describing: (expr as! NumberLiteralNode).number!)
            
        case is VariableNode:
            if let id = (expr as! VariableNode).identifier {
                return id
            }
            break
            
        case is BooleanLiteralNode:
            return (expr as! BooleanLiteralNode).value
            
        case is FunctionCallNode:
            return createFunctionCall(call: (expr as! FunctionCallNode))
            
        default:
            return ""
        }
        
        return ""
    }
    
    private func createExpressionNode(expr: ExpressionNode) -> String {
         guard let op = expr.op, let ops = op.op, let lop = expr.loperand, let rop = expr.roperand else { return "" }
        
        var str = ""
        str += createExpression(expr: lop)
        str += " "
        str += ops
        str += " "
        str += createExpression(expr: rop)
        
        return str
    }
    
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
    
    private func createIfElseNode(ifElse: IfElseNode) -> String {
        guard let iblock = ifElse.ifBlock, let eblock = ifElse.elseBlock, let cond = ifElse.condition else { return "" }
        var str = ""
        
        str += "if("
        str += createExpression(expr: cond)
        str += ")"
        str += createBlock(block: iblock)
        str += " else "
        str += createBlock(block: eblock)
        
        return str
    }
    
    private func createLetNode(letN: LetNode) -> String {
        guard let block = letN.block, let bexpr = block.expression else { return "" }
        
        // Lav intern funktion til let blok
        let intFuncName:String = "_internalLetBlock"+String(self.letIndex)
        let intFuncDef:String = self.curFunctionRet+" "+intFuncName+"("+self.curFunctionPars+")"
        self.funcDecls.append(intFuncDef)
        self.letIndex += 1
        
        // Lav funktionens indhold
        var intFunc = intFuncDef+"{"
        
        for v in letN.vars {
            guard let ttype = v.type, let type = typeConversions[ttype], let name = v.name, let expr = v.value else { continue }
            intFunc += type+" "+name+" = "
            intFunc += createExpression(expr: expr)
            intFunc += ";\n"
        }
        
        intFunc += createExpression(expr: bexpr)
        intFunc += "}"
        
        self.appendFuncAfter(appFunc: intFunc)
        
        // Lav intern funktions kald og returner denne
        var calPars = ""
        for n in 0 ..< self.curFunctionParsList.count {
            let p = self.curFunctionParsList[n]
            calPars += p.name!
            
            if n != self.curFunctionParsList.count-1 {
                calPars += ", "
            }
        }
        
        let intFuncCall = intFuncName+"("+calPars+")"
        
        return intFuncCall
    }
}
