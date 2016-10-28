//
//  Node.swift
//  Parser
//
//  Created by Christian Lundtofte on 23/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

enum CompilerError : Error {
    case ScannerError
    case ParserError
    case TypeError
}

class Node {
    init() { }
}

class ErrorNode : Node {
    
}

class ProgramNode : Node {
    var functions:[FunctionNode] = []
    
    init(functions: [FunctionNode]) {
        self.functions = functions
    }
}
