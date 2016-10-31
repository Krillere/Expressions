//
//  ParserTables.swift
//  Parser
//
//  Created by Christian Lundtofte on 28/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

class ParserTables {
    static var functions:[String] = ["first", "last", "length", "reverse", "get", "init", "tail"]
    static var types:[String] = []
    
    // Generates a 10 digit long random variable name, as to now allow 'collisions' with user functions
    static func generateNewVariableName() -> String {
        let tmp = randomString(length: 10)
        
        return tmp
    }
    
    static func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
