//
//  Numbers.swift
//  Parser
//
//  Created by Christian Lundtofte on 23/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class NumberNode : Node, CustomStringConvertible {
    var value:String?
    
    init(value: String) {
        self.value = value
    }
    
    override init() { }
    
    var description: String {
        return (value != nil ? value! : "")
    }
}

class NumberLitNode : NumberNode {
    
}

class ParNumberExprNode : NumberNode {
    var content: NumberNode
    
    init(cont: NumberNode) {
        self.content = cont
        super.init()
    }
    
    override var description: String {
        return "(\(self.content))"
    }
}

class NumberOpNode : CustomStringConvertible {
    var op:String
    
    init(op: String) {
        self.op = op
    }
    
    var description: String {
        return op
    }
}

class NumberExprNode : NumberNode {
    var operand1:NumberNode?
    var operand2:NumberNode?
    var op:NumberOpNode?
    
    init(op: NumberOpNode, op1: NumberNode, op2: NumberNode) {
        super.init()
        
        self.op = op
        self.operand1 = op1
        self.operand2 = op2
    }
    
    override var description: String {
        return "\(operand1!) \(op!.op) \(operand2!)"
    }
}
