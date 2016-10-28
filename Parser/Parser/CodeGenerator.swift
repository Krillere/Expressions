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
        
        print("Code: \(internalCode)")
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
        
        emit("\n"+type+" ") // int
        emit(identifier) // main
        emitFunctionParameters(pars: function.pars) // ( T1 p1, T2 p2 ... )
        emitBlock(block: block) // { exprs }
    }
    
    // Laver parametre til funktionserklæring
    private func emitFunctionParameters(pars: [ParameterNode]) {
        emit("(")
        
        for n in 0 ..< pars.count {
            let par = pars[n]
            guard let tmpType = par.type, let type = typeConversions[tmpType], let name = par.name else { continue }
            emit(type+" "+name)
            
            if n != pars.count-1 {
                emit(", ")
            }
        }
        
        emit(")")
    }
    
    // Laver en blok
    private func emitBlock(block: BlockNode) {
        emit(" { \n")
        
        if let expr = block.expression {
            emitExpression(expr: expr)
        }
        
        emit("}")
    }
    
    private func emitExpression(expr: Node) {
        switch expr {
        case is IfElseNode:
            emitIfElseNode(ifElse: (expr as! IfElseNode))
            break
            
        case is LetNode:
            emitLetNode(letN: (expr as! LetNode))
        break
            
        case is NumberLiteralNode:
            emit(String(describing: (expr as! NumberLiteralNode).number!))
        break
            
        
            
        default:
            break
        }
    }
    
    private func emitIfElseNode(ifElse: IfElseNode) {
        guard let iblock = ifElse.ifBlock, let eblock = ifElse.elseBlock, let cond = ifElse.condition else { return }
        
        emit("if(")
        emitExpression(expr: cond)
        emit(")")
        emitBlock(block: iblock)
        emit(" else ")
        emitBlock(block: eblock)
    }
    
    private func emitLetNode(letN: LetNode) {
        guard let block = letN.block, let bexpr = block.expression else { return }
        
        emit("{")
        for v in letN.vars {
            guard let ttype = v.type, let type = typeConversions[ttype], let name = v.name, let expr = v.value else { continue }
            
            emit(type+" "+name+" = ") // int myVar =
            emitExpression(expr: expr) // 1
            emit(";\n") // ;
        }
        
        emitExpression(expr: bexpr)
        
        emit("}")
    }
}
