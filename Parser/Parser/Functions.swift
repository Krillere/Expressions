//
//  Functions.swift
//  Parser
//
//  Created by Christian Lundtofte on 27/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class FunctionNode : Node {
    var identifier:String?
    var block:BlockNode?
    var pars:[ParameterNode] = []
    var retType:String?
    
    init(identifier: String, pars: [ParameterNode], ret: String, block: BlockNode) {
        self.identifier = identifier
        self.pars = pars
        self.retType = ret
        self.block = block
        
        print("Funktion lavet: '\(identifier)', parametre: \(pars), returnerer: \(ret)")
    }
    
    override init() { }
}

class ParameterNode : Node, CustomStringConvertible  {
    var type: String?
    var name: String?
    
    init(type: String, name: String) {
        self.type = type
        self.name = name
    }
    
    var description: String {
        return "'"+type!+" "+name!+"'"
    }
}


class BlockNode : Node {
    var expression:Node?
}
