//
//  Node.swift
//  Parser
//
//  Created by Christian Lundtofte on 23/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

// Base Node class
class Node {
    var parent:Node?
    
    init() { }
}



// General program. Contains types and functions
class ProgramNode : Node {
    var functions:[FunctionNode] = []
    var types:[ObjectTypeNode] = []
}

// MARK: Object types
class ObjectTypeNode : Node, CustomStringConvertible {
    var variables:[ObjectTypeVariableNode] = []
    var name:String?
    
    init(variables: [ObjectTypeVariableNode], name: String) {
        super.init()
        
        self.variables = variables
        self.name = name
        
        for v in self.variables {
            v.parent = self
        }
    }
    
    var description: String {
        return "ObjectType"
    }
}

// Variables in object type
class ObjectTypeVariableNode : Node, CustomStringConvertible {
    var identifier:String?
    var type:TypeNode?
    
    init(identifier: String, type: TypeNode) {
        self.identifier = identifier
        self.type = type
    }
    
    var description: String {
        return "VariableNode"
    }
}

// MARK: Function

// Function declaration
class FunctionNode : Node, CustomStringConvertible {
    var identifier:String?
    var block:BlockNode?
    var pars:[ParameterNode] = []
    var retType:TypeNode?
    
    init(identifier: String, pars: [ParameterNode], ret: TypeNode, block: BlockNode) {
        super.init()
        
        self.identifier = identifier
        self.pars = pars
        self.retType = ret
        self.block = block
        
        self.block?.parent = self
        for p in pars {
            p.parent = self
        }
    }
    
    override init() { }
    
    var description: String {
        return "\(retType) \(identifier)"
    }
}

// Parameter in function declaration
class ParameterNode : Node, CustomStringConvertible  {
    var name:String?
    var type: TypeNode?
    
    init(type: TypeNode, name: String) {
        super.init()
        
        self.type = type
        self.name = name
    }
    
    var description: String {
        return "'\(type) "+name!+"'"
    }
}

// Block (Wrapper for 'expression', basically)
class BlockNode : Node {
    var expression:Node?
    
    override init() { }
    
    init(expr: Node) {
        super.init()
        
        self.expression = expr
        self.expression?.parent = self
    }
}

// Function call node: name and parameters
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

class TypeNode : Node { }

// Type declaration (Int, String, CustomType, [Int] and such)
class NormalTypeNode : TypeNode, CustomStringConvertible {
    var fullString:String?
    
    var intClearType:String?
    var clearType:String? {
        set(nval) {
            self.intClearType = nval
            self.generic = (nval == "Generic")
        }
        get {
            return intClearType
        }
    }
    var numNested:Int?
    var generic:Bool = false
    
    override init() { }
    
    init(full: String, type: String, nestedLevel: Int) {
        self.fullString = full
        self.intClearType = type
        self.numNested = nestedLevel
        
        self.generic = (type == "Generic")
    }
    
    
    
    var description: String {
        return String(describing: self.fullString)
    }
}

class FunctionTypeNode : TypeNode, CustomStringConvertible {
    var ret:TypeNode?
    var inputs:[TypeNode] = []
    
    var description: String {
        return "Ret: \(ret), inputs: \(inputs)"
    }
}


// MARK: Literals and variable names
class VariableNode : Node, CustomStringConvertible {
    var identifier:String?
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    var description: String {
        return self.identifier!
    }
}

// Int or Float value
class NumberLiteralNode : Node, CustomStringConvertible {
    var intValue:Int?
    var floatValue:Float?
    
    init(number: Float) {
        self.floatValue = number
    }
    
    init(number: Int) {
        self.intValue = number
    }
    
    var description: String {
        return "Tal"
    }
}

// true || false
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

// String literal: "abcdef .. "
class StringLiteralNode : Node, CustomStringConvertible {
    var content:String?
    
    init(content: String) {
        self.content = content
    }
    
    var description: String {
        return "String("+self.content!+")"
    }
}

class CharLiteralNode : Node, CustomStringConvertible {
    var content:String?
    
    init(content: String) {
        self.content = content
    }
    
    var description: String {
        return "Char(\(self.content))"
    }
}

// Accessing a property from a type
class PropertyValueNode : Node, CustomStringConvertible {
    var name:String?
    var property:String?
    var call:FunctionCallNode?
    
    override init() { }
    
    init(name: String, property: String) {
        self.name = name
        self.property = property
    }
    
    var description: String {
        return "\(self.name) . \(self.property)"
    }
}

// A list of expressions: [expr, expr, expr ... ]
class ArrayLiteralNode : Node, CustomStringConvertible {
    var contents:[Node] = []
    
    init(nodes: [Node]) {
        super.init()
        
        self.contents = nodes
        
        for c in self.contents {
            c.parent = self
        }
    }
    
    var description: String {
        var str = "["
        
        for n in 0 ..< self.contents.count {
            let node = self.contents[n]
            str += String(describing: node)
            
            if n != self.contents.count-1 {
                str += ", "
            }
        }
        
        str += "]"
        return str
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

// Node wrapper for operators
class OperatorNode : Node, CustomStringConvertible {
    var op: String?
    
    init(op: String) {
        self.op = op
    }
    
    var description: String {
        return self.op!
    }
}

// Node for: expr OP expr
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


// MARK: Let
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

// Variable in 'let', for example "Int a = 1"
class LetVariableNode : Node, CustomStringConvertible {
    var type:TypeNode?
    var value:Node?
    var name:String?
    
    init(type: TypeNode, name: String, value: Node) {
        super.init()
        
        self.type = type
        self.value = value
        self.name = name
        
        self.value?.parent = self
    }
    
    var description: String {
        return "'"+String(describing: self.type!)+" "+self.name!+" = "+String(describing: value)+"'"
    }
}


// MARK: switch
class SwitchNode : Node {
    var cases:[SwitchCaseNode] = []
    
    init(cases: [SwitchCaseNode]) {
        super.init()
        
        self.cases = cases
        for c in self.cases {
            c.parent = self
        }
    }
}

// En case i switch (cond block)
class SwitchCaseNode : Node, CustomStringConvertible {
    var expr:Node?
    var block:BlockNode?
    
    init(expr: Node, block: BlockNode) {
        super.init()
        
        self.expr = expr
        self.block = block
        
        self.expr?.parent = self
        self.block?.parent = self
    }
    
    var description: String {
        return "Switch case!"
    }
}

// Used to stop 'switch'
class ElseNode : Node { }


