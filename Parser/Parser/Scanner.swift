//
//  Scanner.swift
//  Parser
//
//  Created by Christian Lundtofte on 23/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

enum TokenType {
    case boolLiteral // AND|OR
    case boolOperator // true|false
    case letter // (a-Z)
    case lpar // "("
    case rpar // ")"
    case none // Fuck.
    case number // (0-9)
    case string // (a-Z)+
    case equal // "="
    case numOperator // + - * /
    case keyword_var // "var"
}

class Token {
    var content:String = ""
    var type:TokenType = .none
    
    init(cont: String, type: TokenType) {
        self.content = cont
        self.type = type
    }
    
    static func emptyToken() -> Token {
        return Token(cont: "", type: .none)
    }
}

class Scanner {
    private let letters = NSCharacterSet.letters
    private let digits = NSCharacterSet.decimalDigits
    private let keywords = ["var"]
    
    private var input:[UInt16] = []
    private var inputIndex = 0
    private var token:Token = Token.emptyToken()
    
    private var char:UnicodeScalar = " "
    private var ident:UnicodeScalar = " "
    private var string:String = ""
    private var intValue:Int = 0
    
    init(input: String) {
        self.input = Array(input.utf16)
    }
    
    // Finder næste char
    private func get() -> UnicodeScalar {
        
        if inputIndex > input.count-1 {
            return UnicodeScalar(1)
        }
        let tmp = UnicodeScalar(input[inputIndex])!
        inputIndex += 1
        return tmp
    }
    
    // Henter tal fra index
    private func getNumber() -> Int {
        var tmp:String = ""
        
        repeat {
            if digits.contains(char) {
                let c = Character(char)
                tmp.append(c)
            }
            char = get()
        }
        while digits.contains(char)
        
        if inputIndex >= input.count-1 { }
        else {
            inputIndex -= 1
        }
        
        return Int(tmp)!
    }
    
    // Henter streng fra index
    private func getString() -> String {
        var tmp:String = ""
        
        repeat {
            tmp.append(Character(char))
            char = get()
        }
        while letters.contains(char)
        
        if inputIndex >= input.count-1 { }
        else {
            inputIndex -= 1
        }
        
        return tmp
    }
    
    // Henter navn fra index (char efterfulgt af chars eller tal)
    private func getName() -> String {
        var tmp:String = ""
        
        if letters.contains(char) {
            tmp.append(Character(char))
            char = get()
        }
        else {
            return ""
        }
        
        repeat {
            tmp.append(Character(char))
            char = get()
        }
        while letters.contains(char) || digits.contains(char)
        
        if inputIndex >= input.count-1 { }
        else {
            inputIndex -= 1
        }
        
        return tmp
    }
    
    
    
    // Finder token ud fra string
    private func parseString() -> Token? {
        
        switch string {
            case "true", "false":
                return Token(cont: string, type: .boolLiteral)
            
            case "OR", "AND":
                return Token(cont: string, type: .boolOperator)
            
            case "var":
                return Token(cont: string, type: .keyword_var)
            
            default:
                return Token(cont: string, type: .string)
        }
    }
    
    
    // Printer fra nuværende char og fremad
    func printRest() {
        for i in inputIndex ..< input.count {
            print(UnicodeScalar(input[i]))
        }
    }
    
    // Fortsætter læsningen
    func getToken() -> Token {
        // Fjern whitespace
        while(inputIndex < input.count) {
            let tmpChar = UnicodeScalar(input[inputIndex])
            
            if tmpChar != " " && tmpChar != "\t" && tmpChar != "\n" {
                break
            }
            
            inputIndex += 1
        }
        
        if inputIndex > input.count-1 {
            return Token.emptyToken()
        }
        
        char = get() // Hent nuværende karakter
        
        if letters.contains(char) { // Bogstav
            string = getString()
            
            token = Token(cont: string, type: .string)
            
            if let token = parseString() {
                self.token = token
            }
        }
        else if digits.contains(char) { // Tal
            intValue = getNumber()
            token = Token(cont: String(intValue), type: .number)
        }
        else { // Special karakterer
            switch char {
            case "(":
                token = Token(cont: "(", type: .lpar)
                break
                
            case ")":
                token = Token(cont: ")", type: .rpar)
                break
            
            case "-": // Undersøg kontekst. Den kan stå i midten af en expression, eller foran et nummer
                char = get()
                if digits.contains(char) {
                    intValue = getNumber()
                    token = Token(cont: "-"+String(intValue), type: .number)
                }
                else { // I en expression
                    token = Token(cont: "-", type: .numOperator)
                }
                break
                
            case "=":
                token = Token(cont: "=", type: .equal)
                break
                
            case "+":
                token = Token(cont: "+", type: .numOperator)
                break
                
            case "*":
                token = Token(cont: "*", type: .numOperator)
                break
                
            case "/":
                token = Token(cont: "/", type: .numOperator)
                break
                
            default:
                token = Token.emptyToken()
                break
            }
        }
        
        return token
    }
}
