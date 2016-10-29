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
        
        print("Code:")
        print(internalCode)
    }
    
    private func emit(_ str: String) {
        internalCode += str
    }

    // Generer funktioner
    private func emitFunction(function: FunctionNode) {
        guard let retType = function.retType,
            let identifier = function.identifier,
            let type = typeConversions[retType],
            let block = function.block else { return }
        
        
        let pars = createFunctionParameters(pars: function.pars)
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
        
        var str = "{\n"
        str += createExpression(expr: block.expression!)
        str += "\n}\n"
        
        return str
    }
    
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
            else {
                tmpNode = par
            }
        }
        
        return false
    }
    
    private func createExpression(expr: Node) -> String {
        if expr is IfElseNode {
            return createIfElseNode(ifElse: (expr as! IfElseNode))
        }
        else if expr is LetNode {
            return createLetNode(letN: (expr as! LetNode))
        }
        
        var retString = ""
        
        let shouldRet = shouldReturn(node: expr)
        if shouldRet {
            retString = "return "
            //print("Returnerer: \(expr)")
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
            retString += String(describing: (expr as! NumberLiteralNode).number!)
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
            
        default:
            retString += ""
            break
        }
        
        if shouldRet {
            retString += ";"
        }
        
        return retString
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
        str += ")\n"
        str += createBlock(block: iblock)
        str += "\n else "
        str += createBlock(block: eblock)
        
        return str
    }
    
    private func createLetNode(letN: LetNode) -> String {
        guard let block = letN.block, let bexpr = block.expression else { return "" }
        

        // Lav funktionens indhold
        var str = "{"
        
        for v in letN.vars {
            guard let ttype = v.type, let type = typeConversions[ttype], let name = v.name, let expr = v.value else { continue }
            str += type+" "+name+" = "
            str += createExpression(expr: expr)
            str += ";\n"
        }
        
        str += createExpression(expr: bexpr)
        str += "}"
        
        return str
    }
}
