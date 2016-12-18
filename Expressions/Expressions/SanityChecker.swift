//
//  SanityChecker.swift
//  Expressions
//
//  Created by Christian Lundtofte on 18/12/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class SanityChecker: TreeWalker {
    override func walkBlockNode(node: BlockNode) {
        if node.expressions.count == 1 {
            return
        }
        
        var numRegularExpressions = 0
        for expr in node.expressions {
            
            if expr is FunctionCallNode {
                guard let expr = expr as? FunctionCallNode, let ident = expr.identifier else { continue }
                if !ParserTables.shared.sideConditionFunctions.contains(ident) {
                    numRegularExpressions += 1
                }
            }
            else {
                numRegularExpressions += 1
            }
        }
        
        if numRegularExpressions > 1 {
            Compiler.error(reason: "Multiple expressions does not make sense.", node: node, phase: .SanityCheck)
        }
    }
}
