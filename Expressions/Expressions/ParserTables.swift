//
//  ParserTables.swift
//  Parser
//
//  Created by Christian Lundtofte on 28/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ParserTables {
    static let shared = ParserTables()
    
    var randomizeNames:Bool = true
    
    var sideConditionFunctions:[String] = ["print", "printLn", "writeFileContents"]
    var functions:[String] = ["first", "last", "length", "reverse", "get", "init", "tail", "append", "list", "factorial", "isInteger", "isFloat", "isCharacter", "isString"]
    var types:[String] = [] // User defined types
    var genericFunctionNames:[String] = []
    
    var nameTranslation:[String : String] = [:]
    
    
    
    init() {
        let builtin = ["print", "printLn", "append", "list", "first", "last", "readFileContents", "writeFileContents", "length", "reverse", "get", "tail", "init", "take", "null", "main", "isInteger", "isFloat", "isCharacter", "isString"]
        for n in builtin {
            nameTranslation[n] = n
        }
        
        self.genericFunctionNames = ["print", "printLn", "null", "length", "append", "list", "get", "take", "first", "last", "init", "tails", "reverse", "isInteger", "isFloat", "isCharacter", "isString"]
    }
    
    // Creates a renamed variable for identifier
    func createRename(forIdentifier: String) -> String {
        if !randomizeNames {
            return forIdentifier
        }
        
        if let known = nameTranslation[forIdentifier] {
            return known
        }
        
        let newName = generateNewVariableName()
        nameTranslation[forIdentifier] = newName
        
        return newName
    }
    
    // Generates a 10 digit long random variable name, as to now allow 'collisions' with user functions
    private func generateNewVariableName() -> String {
        var tmp = randomString(length: 10)
        while nameTranslation.values.contains(tmp) {
            tmp = randomString(length: 10)
        }
        
        return tmp
    }
    
    private func randomString(length: Int) -> String {
        
        let fLetters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for i in 0 ..< length {
            if i == 0 {
                let rand = arc4random_uniform(UInt32(fLetters.length))
                var nextChar = fLetters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            else {
                let rand = arc4random_uniform(len)
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
        }
        
        return randomString
    }
}
