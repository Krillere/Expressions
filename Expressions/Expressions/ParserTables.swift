//
//  ParserTables.swift
//  Parser
//
//  Created by Christian Lundtofte on 28/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ParserTables {
    static var sideConditionFunctions:[String] = ["print", "printLn", "writeFileContents"]
    static var functions:[String] = ["first", "last", "length", "reverse", "get", "init", "tail", "append", "list", "factorial"]
    static var types:[String] = [] // User defined types
    static var nameTranslation:[String : String] = [:]
    
    // Creates a renamed variable for identifier
    static func createRename(forIdentifier: String) -> String {
        
        if let known = nameTranslation[forIdentifier] {
            return known
        }
        
        let newName = generateNewVariableName()
        nameTranslation[forIdentifier] = newName
        
        return newName
    }
    
    // Generates a 10 digit long random variable name, as to now allow 'collisions' with user functions
    static func generateNewVariableName() -> String {
        var tmp = randomString(length: 10)
        while nameTranslation.values.contains(tmp) {
            tmp = randomString(length: 10)
        }
        
        return tmp
    }
    
    static func randomString(length: Int) -> String {
        
        let fLetters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for i in 0 ..< length {
            let rand = arc4random_uniform(len)
            
            if i == 0 {
                var nextChar = fLetters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
            else {
                var nextChar = letters.character(at: Int(rand))
                randomString += NSString(characters: &nextChar, length: 1) as String
            }
        }
        
        return randomString
    }
}
