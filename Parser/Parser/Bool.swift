//
//  Bool.swift
//  Parser
//
//  Created by Christian Lundtofte on 23/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class BoolNode : Node, CustomStringConvertible {
    var value:String?
    
    init(value: String) {
        self.value = value
    }
    
    override init() { }
    
    var description: String {
        return (value != nil ? value! : "")
    }
}

class BoolLitNode : BoolNode { }

class BoolExprNode : BoolNode {
    var operand1:BoolNode?
    var operand2:BoolNode?
    var op:BoolOpNode?
    
    init(op: BoolOpNode, op1: BoolNode, op2: BoolNode) {
        super.init()
        
        self.op = op
        self.operand1 = op1
        self.operand2 = op2
    }
    
    override var description: String {
        return "\(operand1!) \(op!.op) \(operand2!)"
    }
}

class ParBoolExprNode : BoolNode {
    var content: BoolNode
    
    init(cont: BoolNode) {
        self.content = cont
        super.init()
    }
    
    override var description: String {
        return "(\(self.content))"
    }
}

class BoolOpNode : CustomStringConvertible {
    var op:String
    
    init(op: String) {
        self.op = op
    }
    
    var description: String {
        return op
    }
}
