//
//  TreeHelper.swift
//  Expressions
//
//  Created by Christian Lundtofte on 03/11/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class TreeHelper {
    
    // Does the function have generics as parameter or return type?
    public static func isGenericFunction(node: FunctionNode) -> Bool {
        var isGeneric = false
        
        // Return type
        let ret = node.returnType
        if ret is NormalTypeNode {
            if (ret as! NormalTypeNode).generic {
                isGeneric = true
            }
        }
        
        if !isGeneric {
            for p in node.parameters {
                if p.type is NormalTypeNode {
                    if (p.type as! NormalTypeNode).generic {
                        isGeneric = true
                        break
                    }
                }
            }
        }
        
        return isGeneric
    }

    public static func isObjectType(type: NormalTypeNode) -> Bool {
        guard let nested = type.numNested, let clearType = type.clearType else { return false }
        
        if nested == 0 {
            if ParserTables.shared.types.contains(clearType) {
                return true
            }
        }
        
        for i in 0 ..< nested {
            if i == nested-1 {
                if ParserTables.shared.types.contains(clearType) {
                    return true
                }
            }
        }
        
        return false
    }
}
