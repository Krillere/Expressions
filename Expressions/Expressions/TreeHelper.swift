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
        let ret = node.retType
        if ret is NormalTypeNode {
            if (ret as! NormalTypeNode).generic {
                isGeneric = true
            }
        }
        
        if !isGeneric {
            for p in node.pars {
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
    
    // Does the function have any variadic parameters?
    public static func isVariadicFunction(node: FunctionNode) -> Bool {
        for p in node.pars {
            if p.variadic {
                return true
            }
        }
        
        return false
    }
}
