//
//  ScopeChecker.swift
//  Expressions
//
//  Created by Christian Lundtofte on 29/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ScopeChecker {
    private var program:ProgramNode?
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    func test() {
        guard let program = self.program else { return }
        let _ = program
    }
}
