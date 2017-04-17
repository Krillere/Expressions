//
//  ErrorHandler.swift
//  Expressions
//
//  Created by Christian Lundtofte on 17/04/2017.
//  Copyright © 2017 Christian Lundtofte. All rights reserved.
//

import Foundation

class ErrorHandler {
    static let shared = ErrorHandler()
    
    var errors:[CompilerError] = []
    
    
    func error(reason: String, node: Node, phase: CompilerError.Phase) {
        errors.append(CompilerError(reason: reason, phase: phase, node: node))
    }
}
