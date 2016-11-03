//
//  ParseTableFiller.swift
//  Expressions
//
//  Created by Christian Lundtofte on 03/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ParseTableFiller {
    private var program:ProgramNode?
    
    init(program: ProgramNode) {
        self.program = program
    }
    
    func run() {
        guard let program = self.program else { return }
        
        for f in program.functions {
            guard let ident = f.identifier else { continue }
            
            if TreeHelper.isGenericFunction(node: f) {
                ParserTables.shared.genericFunctionNames.append(ident)
            }
        }
    }
}