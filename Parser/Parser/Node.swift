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
}

class Node {
    init() { }
}

class ErrorNode : Node {
    
}
