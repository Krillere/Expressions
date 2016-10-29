//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

if let p = Bundle.main.path(forResource: "example", ofType: "expr") {
    let cont = try String(contentsOfFile: p)
    
    let ps = Parser(input: cont)
    ps.run()

    if let program = ps.getProgram() {
        let generator = CodeGenerator(program: program)
        generator.generate()
    }
}
