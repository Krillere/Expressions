//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

func compile(code: String) {
    let ps = Parser(input: code)
    ps.run()
    
    let errs = ps.getErrors()
    if errs.count != 0 {
        print("Stopper grundet errors.")
        return
    }
    
    if let program = ps.getProgram() {
        let generator = CodeGenerator(program: program)
        generator.generate()
        
        let intermediate = generator.getIntermediate()
        do {
            try intermediate.write(toFile: NSHomeDirectory()+"/Desktop/intermediate.cpp", atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            print("Error ved gem intermediate: \(error)")
        }
    }
}

if let p = Bundle.main.path(forResource: "example6", ofType: "expr") {
    let cont = try String(contentsOfFile: p)
    compile(code: cont)
}
else {
    print("Ingen fil fundet..")
}
