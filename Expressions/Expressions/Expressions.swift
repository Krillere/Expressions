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
        super.init()
        
        self.identifier = identifier
        self.pars = pars
        self.retType = ret
        self.block = block
        
        self.block?.parent = self
        for p in pars {
            p.parent = self
        }
        
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
    
    override init() { }
    
    init(expr: Node) {
        super.init()
        
        self.expression = expr
        self.expression?.parent = self
    }
}

class FunctionCallNode : Node, CustomStringConvertible {
    var identifier:String?
    var parameters:[Node] = []
    
    init(identifier: String, parameters: [Node]) {
        super.init()
        
        
        self.identifier = identifier
        self.parameters = parameters
        
        for p in self.parameters {
            p.parent = self
        }
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
    var value:String = "false"
    
    init(value: String) {
        if value == "true" {
            self.value = value
        }
    }
    
    var description: String {
        return String(describing: self.value)
    }
}

// MARK: Expressions
class ParenthesesExpression: Node, CustomStringConvertible {
    var expression:Node?
    
    init(expr: Node) {
        super.init()
        
        self.expression = expr
        self.expression?.parent = self
    }
    
    var description: String {
        return "(\(self.expression))"
    }
}

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
        super.init()
        
        self.op = op
        self.loperand = loperand
        self.roperand = roperand
        
        self.op?.parent = self
        self.loperand?.parent = self
        self.roperand?.parent = self
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
        super.init()
        
        self.condition = cond
        self.ifBlock = ifBlock
        self.elseBlock = elseBlock
        
        self.condition?.parent = self
        self.ifBlock?.parent = self
        self.elseBlock?.parent = self
    }
}


// MARK: let
class LetNode : Node, CustomStringConvertible {
    var vars:[LetVariableNode] = []
    var block:BlockNode?
    
    init(vars: [LetVariableNode], block: BlockNode) {
        super.init()
        
        self.vars = vars
        self.block = block
        
        self.block?.parent = self
        for v in vars {
            v.parent = self
        }
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
        super.init()
        
        self.type = type
        self.value = value
        self.name = name
        
        self.value?.parent = self
    }
    
    var description: String {
        return "'"+self.type!+" "+self.name!+" = "+String(describing: value)+"'"
    }
}
