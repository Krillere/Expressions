//
//  Expressions.swift
//  Parser
//
//  Created by Christian Lundtofte on 27/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class IfElseNode : Node {
    var condition:Node?
    var ifBlock:BlockNode?
    var elseBlock:BlockNode?
    
    init(cond: Node, ifBlock: BlockNode, elseBlock: BlockNode) {
        self.condition = cond
        self.ifBlock = ifBlock
        self.elseBlock = elseBlock
    }
}
