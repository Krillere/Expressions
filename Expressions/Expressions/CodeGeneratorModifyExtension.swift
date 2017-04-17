//
//  CodeGeneratorModifyExtension.swift
//  Expressions
//
//  Created by Christian Lundtofte on 15/12/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

extension CodeGenerator {

    // Called in 'createBlock', as to declare variables in function calls before the function call itself, at the start of a block
    // (Array and String literals are easier to handle as declarations, than they are in the calls, I think.)
    // Example: myFunc([1, 2, 3]) -> std::vector<int> tmp = {1, 2, 3}; myFunc(tmp);
    internal func createFunctionCallParameterDeclarations(expr: Node) -> String {
        
        if expr is FunctionCallNode { // Found function call, declare parameters and exchange them for the variablename
            guard let fc = expr as? FunctionCallNode,
                let ident = fc.identifier else { return "" }
            
            var str = ""
            // Iterate parameters (Some might need to be changed)
            for n in 0 ..< fc.parameters.count {
                let par = fc.parameters[n]
                
                // ArrayLiterals are replaced
                if par is ArrayLiteralNode {
                    guard let par = par as? ArrayLiteralNode else { continue }
                    
                    // Replacements for contents of array literal (Could contain nested lists or calls or something)
                    for c in par.contents {
                        str += createFunctionCallParameterDeclarations(expr: c)
                    }
                    
                    // Create a new name and refer it to itself in translation
                    let newName = ParserTables.shared.generateNewVariableName()
                    ParserTables.shared.nameTranslation[newName] = newName
                    
                    // Replace literal with reference to variable
                    let replacementNode = VariableNode(identifier: newName)
                    fc.parameters[n] = replacementNode
                    
                    // If the function is generic, guess the type. If not, find in function declaration
                    var type = ""
                    if ParserTables.shared.genericFunctionNames.contains(ident) {
                        type = "std::vector<"+CodeGeneratorHelpers.guessTypeString(node: par)+">"
                    }
                    else { // 'Normal' function
                        if let functionDecl = CodeGeneratorHelpers.determineFunctionNodeForCall(call: fc) {
                            if n >= functionDecl.parameters.count {
                                break
                            }
                            
                            if let defParType = functionDecl.parameters[n].type as? NormalTypeNode {
                                if functionDecl.parameters[n].variadic {
                                    type = "std::vector<"+createTypeString(type: defParType)+">"
                                }
                                else {
                                    type = createTypeString(type: defParType)
                                }
                            }
                            else {
                                ErrorHandler.shared.error(reason: "Failed determining the type of parameter.", node: expr, phase: .CodeGeneration)
                            }
                        }
                        else {
                            ErrorHandler.shared.error(reason: "No function node found for function call '\(ident)'", node: expr, phase: .CodeGeneration)
                        }
                    }
                    
                    str += type+" "+newName+" = "+createArrayLiteral(lit: par)+";\n"
                }
                else if par is StringLiteralNode { // String literal used as parameter, replace with std::vector<char>
                    guard let par = par as? StringLiteralNode else { continue }
                    
                    // Create a new name and refer it to itself in translation
                    let newName = ParserTables.shared.generateNewVariableName()
                    ParserTables.shared.nameTranslation[newName] = newName
                    
                    // Replace the literal with a reference to the variable
                    let replacementNode = VariableNode(identifier: newName)
                    fc.parameters[n] = replacementNode
                    
                    str += "std::vector<char> "+newName+" = "+createStringLiteral(string: par)+";\n"
                }
                else if par is FunctionCallNode { // Do the same for nested function calls
                    str += createFunctionCallParameterDeclarations(expr: par)
                }
                else if par is VariableNode {
                    guard let par = par as? VariableNode,
                        let variableIdentifier = par.identifier,
                        let _ = ParserTables.shared.functionDeclarations[ident], // Function we're calling
                        let tryCallFuncs = ParserTables.shared.functionDeclarations[variableIdentifier] else { continue }
                    
                    
                    // Figure out the exact function, based on the call (Necessary for overloading)
                    if let funcDecl = CodeGeneratorHelpers.determineFunctionNodeForCall(call: fc) {
                        let tryCallingDecl = tryCallFuncs[0]
                        
                        // If this is a function type argument, pre-declare it.
                        if funcDecl.isFunctionType(index: n) {
                            
                            // Create a new name and refer it to itself in translation
                            let newName = ParserTables.shared.generateNewVariableName()
                            ParserTables.shared.nameTranslation[newName] = newName
                            
                            // Replace literal with reference to variable
                            let replacementNode = VariableNode(identifier: newName)
                            fc.parameters[n] = replacementNode
                            
                            let tmpStr = createFunctionTypeDefinition(function: tryCallingDecl)+" "+newName+" = "+variableIdentifier+";\n"
                            str += tmpStr
                        }
                    }
                }
                else if par is LambdaNode {
                    guard let par = par as? LambdaNode, let retType = par.returnType, let block = par.block else { continue }
                    // Replace node with variable
                    let newName = ParserTables.shared.generateNewVariableName()
                    ParserTables.shared.nameTranslation[newName] = newName
                    
                    let repNode = VariableNode(identifier: newName)
                    fc.parameters[n] = repNode
                    
                    // Create lambda definition (Create tmp function so we can reuse 'createFunctionTypeDefinition)
                    let tmpNode = FunctionNode(identifier: "", pars: par.parameters, ret: retType, block: block)
                    str += createFunctionTypeDefinition(function: tmpNode)
                    
                    // Anonumous function
                    let lambda = createLambdaNode(node: par)
                    
                    str += " "+newName+" = "+lambda+";\n"
                }
            }
            
            return str
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
        else if expr is NegateExpression {
            guard let expr = expr as? NegateExpression, let nestedExpr = expr.expression else { return "" }
            return createFunctionCallParameterDeclarations(expr: nestedExpr)
        }
        else if expr is MinusExpression {
            guard let expr = expr as? MinusExpression, let nestedExpr = expr.expression else { return "" }
            return createFunctionCallParameterDeclarations(expr: nestedExpr)
        }
        else if expr is IfElseNode {
            guard let expr = expr as? IfElseNode, let econd = expr.condition else { return "" }
            return createFunctionCallParameterDeclarations(expr: econd)
        }
        else if expr is SwitchNode {
            guard let expr = expr as? SwitchNode else { return "" }
            var str = ""
            
            for c in expr.cases {
                guard let cexpr = c.expr else { continue }
                str += createFunctionCallParameterDeclarations(expr: cexpr)
            }
            
            return str
        }
        
        return ""
    }
    
    internal func createExpressionArrayLiterals(expr: Node) -> String {
        var str = ""
        
        if expr is ArrayLiteralNode {
            
        }
        else if expr is ExpressionNode {
            guard let expr = expr as? ExpressionNode, let lExpr = expr.loperand, let _ = expr.op, let rExpr = expr.roperand else { return "" }
            
            str += createExpressionArrayLiterals(expr: lExpr)
            str += createExpressionArrayLiterals(expr: rExpr)
        }
        
        return str
    }
}
