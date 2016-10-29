//
//  Scanner.swift
//  Parser
//
//  Created by Christian Lundtofte on 23/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

enum TokenType {
    case lpar // "("
    case rpar // ")"
    case lcurly // {
    case rcurly // }
    case lsquare // [
    case rsquare // ]
    
    case boolLiteral   // true|false
    
    case op // AND | OR | * | + | / | - | < | > | <= | >= | == | !=
    
    case number         // (0-9)
    case string         // (a-Z)+
    case stringLiteral  // "(.*)"
    
    case equal          // =
    case semicolon      // ;
    case colon          // :
    case questionMark   // ?
    case returns        // ->
    case comma          // ,
    case negate         // !
    
    case keyword_if     // "if"
    case keyword_else   // "else"
    case keyword_define // "define"
    case keyword_let    // "let"
    case keyword_switch // "switch"
    
    case none           // EOF som regel
}

class Token : CustomStringConvertible {
    var content:String = ""
    var type:TokenType = .none
    var intValue:Int?
    var floatValue:Float?
    
    init(cont: String, type: TokenType, charIndex: Int) {
        self.content = cont
        self.type = type
    }
    
    static func emptyToken(_ index: Int) -> Token {
        return Token(cont: "", type: .none, charIndex: index)
    }
    
    var description: String {
        return "Token: \(self.type) - '\(self.content)'"
    }
}

class Scanner {
    private let letters = NSCharacterSet.letters
    private let digits = NSCharacterSet.decimalDigits
    private let otherNameChars = CharacterSet(charactersIn: "'-_")

    private var input:[UInt16] = []
    private var inputIndex = 0
    private var token:Token = Token.emptyToken(0)
    
    private var char:UnicodeScalar = " "
    private var ident:UnicodeScalar = " "
    private var string:String = ""
    private var intValue:Int = 0
    private var floatValue:Float = 0
    
    private var allTokens:[Token] = []
    private var tokenIndex:Int = 0
    
    init(input: String) {
        self.input = Array(input.utf16)
        self.fetchAllTokens()
    }
    
    private func fetchAllTokens() {
        var tmpToken = Token.emptyToken(0)
        
        repeat {
            tmpToken = intGetToken()
            allTokens.append(tmpToken)
        }
        while tmpToken.type != .none
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
    private func getNumberString() -> String {
        var tmp:String = ""
        
        repeat {
            if digits.contains(char) {
                let c = Character(char)
                tmp.append(c)
            }
            char = get()
        }
        while digits.contains(char)
        
        if char == "." { // But wait, there's more!
            tmp.append(".")
            
            repeat {
                if digits.contains(char) {
                    let c = Character(char)
                    tmp.append(c)
                }
                char = get()
            }
            while digits.contains(char)
        }
        
        if inputIndex >= input.count-1 { }
        else {
            inputIndex -= 1
        }
        
        return tmp//Int(tmp)!
    }
    
    private func isFloating(test: String) -> Bool {
        return test.contains(".")
    }
    
    // Henter streng fra index
    private func getString() -> String {
        var tmp:String = ""
        
        repeat {
            tmp.append(Character(char))
            char = get()
        }
        while letters.contains(char) || digits.contains(char) || otherNameChars.contains(char)
        
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
    
    private func getStringLiteralContent() -> String {
        var stringContent = ""
        
        char = get()
        while char != "\"" {
            stringContent.append(Character(char))
            char = get()
        }
        
        return stringContent
    }
    
    
    // Finder token ud fra string
    private func parseString() -> Token? {
        
        var type:TokenType = .string
        
        switch string {
            case "true", "false":
                type = .boolLiteral
            break
            
            case "OR", "AND":
                type = .op
            break
            
            case "define":
                type = .keyword_define
            break
            
            case "if":
                type = .keyword_if
            break
            
            case "else":
                type = .keyword_else
            break
            
            case "let":
                type = .keyword_let
            break
            
            case "switch":
                type = .keyword_switch
            break
            
            default:
                type = .string
            break
        }
        
        return Token(cont: string, type: type, charIndex: inputIndex)
    }
    

    // Returnerer token og tilføjer til index
    func getToken() -> Token {
        if tokenIndex > allTokens.count-1 {
            return Token.emptyToken(-1)
        }
        
        let token = allTokens[tokenIndex]
        tokenIndex += 1
        
        return token
    }

    
    // Lader brugeren kigge 'num' tokens frem (0 som default)
    func peekToken(num: Int = 0) -> Token {
        if tokenIndex+num > allTokens.count-1 {
            return Token.emptyToken(-1)
        }
        
        let token = allTokens[tokenIndex+num]
        return token
    }
    
    // Finder næste token, bruges kun internt
    private func intGetToken() -> Token {
        // Fjern whitespace
        while(inputIndex < input.count) {
            let tmpChar = UnicodeScalar(input[inputIndex])
            
            if tmpChar != " " && tmpChar != "\t" && tmpChar != "\n" {
                break
            }
            
            inputIndex += 1
        }
        
        if inputIndex > input.count-1 {
            return Token.emptyToken(inputIndex)
        }
        
        char = get() // Hent nuværende karakter
        
        if letters.contains(char) { // Bogstav
            string = getString()
            
            token = Token(cont: string, type: .string, charIndex: inputIndex)
            
            if let token = parseString() {
                self.token = token
            }
        }
        else if digits.contains(char) { // Tal
            let intS = getNumberString()
            if isFloating(test: intS) {
                floatValue = Float(intS)!
                
                token = Token(cont: "-"+intS, type: .number, charIndex: inputIndex)
                token.floatValue = floatValue
            }
            else {
                intValue = Int(intS)!
                
                token = Token(cont: String(intValue), type: .number, charIndex: inputIndex)
                token.intValue = intValue
            }
        }
        else { // Special karakterer
            switch char {
            case "(":
                token = Token(cont: "(", type: .lpar, charIndex: inputIndex)
                break
                
            case ")":
                token = Token(cont: ")", type: .rpar, charIndex: inputIndex)
                break
            
            case "-": // Undersøg kontekst. Den kan stå i midten af en expression, eller foran et nummer eller evt. returns
                char = get()

                if digits.contains(char) {
                    let intS = "-"+getNumberString()
                    if isFloating(test: intS) {
                        floatValue = Float(intS)!
                        
                        token = Token(cont: "-"+intS, type: .number, charIndex: inputIndex)
                        token.floatValue = floatValue
                    }
                    else {
                        intValue = Int(intS)!
                        
                        token = Token(cont: "-"+intS, type: .number, charIndex: inputIndex)
                        token.intValue = intValue
                    }
                }
                else if char == ">" { // returns
                    token = Token(cont: ">", type: .returns, charIndex: inputIndex)
                }
                else { // I en expression
                    token = Token(cont: "-", type: .op, charIndex: inputIndex)
                }
                break
                
            case "=":
                let tmp = get()
                
                if tmp == "=" {
                    token = Token(cont: "==", type: .op, charIndex: inputIndex)
                }
                else {
                    inputIndex -= 1
                    token = Token(cont: "=", type: .equal, charIndex: inputIndex)
                }
                break
                
            case "+":
                token = Token(cont: "+", type: .op, charIndex: inputIndex)
                break
                
            case "*":
                token = Token(cont: "*", type: .op, charIndex: inputIndex)
                break
                
            case "#":
                print("Kommentar!")
            break
                
            case "/":
                token = Token(cont: "/", type: .op, charIndex: inputIndex)
                break
                
            case ";":
                token = Token(cont: ";", type: .semicolon, charIndex: inputIndex)
                break
                
            case "?":
                token = Token(cont: "?", type: .questionMark, charIndex: inputIndex)
            break
                
            case ":":
                token = Token(cont: ":", type: .colon, charIndex: inputIndex)
            break
                
            case "{":
                token = Token(cont: "{", type: .lcurly, charIndex: inputIndex)
            break
                
            case "}":
                token = Token(cont: "}", type: .rcurly, charIndex: inputIndex)
            break
                
            case "[":
                token = Token(cont: "[", type: .lsquare, charIndex: inputIndex)
            break
                
            case "]":
                token = Token(cont: "]", type: .rsquare, charIndex: inputIndex)
            break
                
            case ",":
                token = Token(cont: ",", type: .comma, charIndex: inputIndex)
            break
                
            case "<":
                let test = get()
                if test == "=" {
                    token = Token(cont: "<=", type: .op, charIndex: inputIndex)
                }
                else {
                    inputIndex -= 1
                    token = Token(cont: "<", type: .op, charIndex: inputIndex)
                }
            break
                
            case ">":
                let test = get()
                if test == "=" {
                    token = Token(cont: ">=", type: .op, charIndex: inputIndex)
                }
                else {
                    inputIndex -= 1
                    token = Token(cont: ">", type: .op, charIndex: inputIndex)
                }
            break
                
            case "!":
                let test = get()
                if test == "=" {
                    token = Token(cont: "!=", type: .op, charIndex: inputIndex)
                }
                else {
                    inputIndex -= 1
                    token = Token(cont: "!", type: .op, charIndex: inputIndex)
                }
            break
                
            case "\"":
                let stringLit = getStringLiteralContent()
                token = Token(cont: stringLit, type: .stringLiteral, charIndex: inputIndex)
            break
                
            default:
                token = Token.emptyToken(inputIndex)
                break
            }
        }
        
        return token
    }
}
