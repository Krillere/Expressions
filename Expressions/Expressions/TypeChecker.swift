//
//  TypeChecker.swift
//  Parser
//
//  Created by Christian Lundtofte on 28/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class TypeChecker {
    private var program:ProgramNode?
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    func run() {
        guard let program = self.program else { return }
        let _ = program
    }
}
