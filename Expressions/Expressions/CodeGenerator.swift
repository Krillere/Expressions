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
    private var typeConversions:[String: String] = ["Int":"int", "Char":"char", "Float":"float", "String":"std::string"]
    private var opConversions:[String: String] = ["AND":"&&", "OR":"||"]
    
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    // Laver og printer kode
    func generate() {
        guard let program = self.program else { return }
        let functions = program.functions
        
        for function in functions {
            emitFunction(function: function)
        }
        
        
        // Imports og declarations og shitz
        var decls = "// Prototypes \n"
        for dec in declaredFunctions {
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
        declaredFunctions.append(type+" "+identifier+"("+pars+")")
        
        emit("\n"+type+" ") // int
        emit(identifier) // main
        emit("("+pars+")")
        emit(createBlock(block: block))
    }
    
    // Laver string med funktionsparametre - (T1 n1, T2 n2 ... )
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

    // Laver en blok - { expr }
    private func createBlock(block: BlockNode) -> String {
        
        var str = "{\n"
        str += createExpression(expr: block.expression!)
        str += "\n}\n"
        
        return str
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
            
        default:
            retString += ""
            break
        }
        
        if shouldRet {
            retString += ";"
        }
        
        return retString
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
