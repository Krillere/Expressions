//
//  Expressions.swift
//  Parser
//
//  Created by Christian Lundtofte on 27/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation


class FunctionNode : Node {
    var identifier:String?
    var block:BlockNode?
    var pars:[ParameterNode] = []
    var retType:String?
    
    init(identifier: String, pars: [ParameterNode], ret: String, block: BlockNode) {
        self.identifier = identifier
        self.pars = pars
        self.retType = ret
        self.block = block
        
        print("Funktion lavet: '\(identifier)', parametre: \(pars), returnerer: \(ret)")
    }
    
    override init() { }
}

class ParameterNode : Node, CustomStringConvertible  {
    var type: String?
    var name: String?
    
    init(type: String, name: String) {
        self.type = type
        self.name = name
    }
    
    var description: String {
        return "'"+type!+" "+name!+"'"
    }
}

class BlockNode : Node {
    var expression:Node?
}

class FunctionCallNode : Node, CustomStringConvertible {
    var identifier:String?
    var parameters:[Node] = []
    
    init(identifier: String, parameters: [Node]) {
        self.identifier = identifier
        self.parameters = parameters
    }
    
    var description: String {
        return "Kald: \(identifier!), med "+String(parameters.count)+" parametre!"
    }
}


// MARK: Literals og variabler
class VariableNode : Node, CustomStringConvertible {
    var identifier:String?
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    var description: String {
        return self.identifier!
    }
}

class NumberLiteralNode : Node, CustomStringConvertible {
    var number:Int?
    
    init(number: Int) {
        self.number = number
    }
    
    var description: String {
        return String(describing: number)
    }
}

class BooleanLiteralNode : Node, CustomStringConvertible {
    var value:Bool = false
    
    init(value: String) {
        if value == "true" {
            self.value = true
        }
    }
    
    var description: String {
        return String(describing: self.value)
    }
}

// MARK: Expressions
class OperatorNode : Node, CustomStringConvertible {
    var op: String?
    
    init(op: String) {
        self.op = op
    }
    
    var description: String {
        return self.op!
    }
}

class ExpressionNode : Node, CustomStringConvertible {
    var op: OperatorNode?
    var loperand: Node?
    var roperand: Node?
    
    init(op: OperatorNode, loperand: Node, roperand: Node) {
        self.op = op
        self.loperand = loperand
        self.roperand = roperand
    }
    
    var description: String {
        return "\(loperand!) \(op!) \(roperand!)"
    }
}

// MARK: If-else
class IfElseNode : Node {
    var condition:Node?
    var ifBlock:BlockNode?
    var elseBlock:BlockNode?
    
    init(cond: Node, ifBlock: BlockNode, elseBlock: BlockNode) {
        self.condition = cond
        self.ifBlock = ifBlock
        self.elseBlock = elseBlock
    }
}


// MARK: let
class LetNode : Node, CustomStringConvertible {
    var vars:[LetVariableNode] = []
    var block:BlockNode?
    
    init(vars: [LetVariableNode], block: BlockNode) {
        self.vars = vars
        self.block = block
    }
    
    var description: String {
        return "Let: \(vars)"
    }
}

class LetVariableNode : Node, CustomStringConvertible {
    var type:String?
    var value:Node?
    var name:String?
    
    init(type: String, name: String, value: Node) {
        self.type = type
        self.value = value
        self.name = name
    }
    
    var description: String {
        return "'"+self.type!+" "+self.name!+" = "+String(describing: value)+"'"
    }
}
