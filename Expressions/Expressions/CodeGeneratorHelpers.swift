//
//  CodeGenerationHelpers.swift
//  Expressions
//
//  Created by Christian Lundtofte on 15/12/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class CodeGeneratorHelpers {
    static func guessType(node: Node) -> TypeNode {
        if node is ArrayLiteralNode {
            guard let node = node as? ArrayLiteralNode else { return NormalTypeNode(full: "void*", type: "void*", nestedLevel: 0) }
            if node.contents.count < 1 {
                return NormalTypeNode(full: "void*", type: "void*", nestedLevel: 1)
            }
            
            let fnode = node.contents[0]
            if fnode is CharLiteralNode {
                return NormalTypeNode(full: "Char", type: "Char", nestedLevel: 1)
            }
            else if fnode is NumberLiteralNode {
                if let fnode = fnode as? NumberLiteralNode {
                    if fnode.floatValue != nil {
                        return NormalTypeNode(full: "Float", type: "Float", nestedLevel: 1)
                    }
                    else if fnode.intValue != nil {
                        return NormalTypeNode(full: "Int", type: "Int", nestedLevel: 1)
                    }
                }
            }
            else if fnode is ArrayLiteralNode {
                return guessType(node: fnode)
            }
            else if fnode is StringLiteralNode {
                return NormalTypeNode(full: "String", type: "String", nestedLevel: 1)
            }

        }
        else if node is NumberLiteralNode {
            if let node = node as? NumberLiteralNode {
                if node.floatValue != nil {
                    return NormalTypeNode(full: "Float", type: "Float", nestedLevel: 0)
                }
                else if node.intValue != nil {
                    return NormalTypeNode(full: "Int", type: "Int", nestedLevel: 0)
                }
            }
        }
        else if node is StringLiteralNode {
            return NormalTypeNode(full: "String", type: "String", nestedLevel: 0)
        }
        else if node is CharLiteralNode {
            return NormalTypeNode(full: "Char", type: "Char", nestedLevel: 0)
        }
        else if node is BooleanLiteralNode {
            return NormalTypeNode(full: "Bool", type: "Bool", nestedLevel: 0)
        }

        return NormalTypeNode(full: "void*", type: "void*", nestedLevel: 0)
    }
    
    // Determine (gues..) the type of a literal (Array is guessing, rest is pretty straight forward) (Guess is fine. C++ compiler catches mistakes..)
    static func guessTypeString(node: Node) -> String {
        
        if node is ArrayLiteralNode {
            guard let node = node as? ArrayLiteralNode else { return "" }
            if node.contents.count < 1 {
                return "void*"
            }
            
            let fnode = node.contents[0]
            if fnode is CharLiteralNode {
                return "char"
            }
            else if fnode is NumberLiteralNode {
                if let fnode = fnode as? NumberLiteralNode {
                    if fnode.floatValue != nil {
                        return "float"
                    }
                    else if fnode.intValue != nil {
                        return "int"
                    }
                }
            }
            else if fnode is ArrayLiteralNode {
                let str = "std::vector<"+guessTypeString(node: fnode)+">"
                return str
            }
            else if fnode is StringLiteralNode {
                return "std::vector<char>"
            }
        }
        else if node is NumberLiteralNode {
            if let node = node as? NumberLiteralNode {
                if node.floatValue != nil {
                    return "float"
                }
                else if node.intValue != nil {
                    return "int"
                }
            }
        }
        else if node is StringLiteralNode {
            return "std::vector<char>"
        }
        else if node is CharLiteralNode {
            return "char"
        }
        else if node is BooleanLiteralNode {
            return "bool"
        }
        
        Compiler.error(reason: "No type found for node: \(node), probably an error.", node: node, phase: .CodeGeneration)
        return ""
    }
}
