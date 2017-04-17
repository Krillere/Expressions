//
//  CompilerError.swift
//  Expressions
//
//  Created by Christian Lundtofte on 17/04/2017.
//  Copyright © 2017 Christian Lundtofte. All rights reserved.
//

import Foundation

class CompilerError : CustomStringConvertible {
    
    enum Phase {
        case Pre
        case Scanning
        case Parsing
        case ScopeCheck
        case TypeCheck
        case SanityCheck
        case CodeGeneration
        case Other
    }
    
    var reason:String?
    var token:Token?
    var phase:Phase?
    var node:Node?
    
    init(reason: String, token: Token) {
        self.reason = reason
        self.token = token
    }
    
    init(reason: String, phase: Phase, node: Node) {
        self.reason = reason
        self.phase = phase
        self.node = node
    }
    
    init(reason: String, phase: Phase) {
        self.reason = reason
        self.phase = phase
    }
    
    var description: String {
        return self.reason!
    }
}
