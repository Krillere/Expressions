//
//  Expressions.swift
//  Parser
//
//  Created by Christian Lundtofte on 27/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation


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
        return "Nope."
    }
}

class LetVariableNode : Node, CustomStringConvertible {
    var type:String?
    var value:Node?
    
    init(type: String, value: Node) {
        self.type = type
        self.value = value
    }
    
    var description: String {
        return self.type!+" = "+String(describing: value)
    }
}
