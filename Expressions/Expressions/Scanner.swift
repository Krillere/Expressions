//
//  Scanner.swift
//  Parser
//
//  Created by Christian Lundtofte on 23/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

// Types of tokens
enum TokenType {
    case lpar // "("
    case rpar // ")"
    case lcurly // {
    case rcurly // }
    case lsquare // [
    case rsquare // ]
    
    case boolLiteral   // true|false
    
    case op // AND | OR | * | + | / | - | < | > | <= | >= | == | != | % | . | ++
    
    case number         // (0-9)
    case string         // (a-Z)+
    case stringLiteral  // "(.*)"
    case char           // '(A-z osv.)'
    
    case equal          // =
    case colon          // :
    case questionMark   // ?
    case returns        // ->
    case comma          // ,
    case negate         // !

    case keyword_if     // "if"
    case keyword_else   // "else"
    case keyword_define // "define"
    case keyword_type   // "type"
    case keyword_let    // "let"
    case keyword_switch // "switch"
    case keyword_lambda // "lambda"
    //case keyword_null   // "null" // Used for constructors
    
    case none           // EOF usually, possibly error
}

class Token : CustomStringConvertible {
    var content:String = ""
    var type:TokenType = .none
    
    var intValue:Int? // Used for Int
    var floatValue:Float? // Used for Float
    
    init(cont: String, type: TokenType, charIndex: Int) {
        self.content = cont
        self.type = type
    }
    
    // First token, or error token (.none is often error)
    static func emptyToken(_ index: Int) -> Token {
        return Token(cont: "", type: .none, charIndex: index)
    }
    
    var description: String {
        return "Token: \(self.type) - '\(self.content)'"
    }
}

class Scanner {
    var owner:Parser?
    
    // Char classes
    private let letters = NSCharacterSet.letters
    private let digits = NSCharacterSet.decimalDigits
    private let otherNameChars = CharacterSet(charactersIn: "_'?")

    // Input and index in input (integer of character)
    private var input:[UInt16] = []
    private var inputIndex = 0
    
    private var token:Token = Token.emptyToken(0)
    
    // Variables used in generating tokens
    private var char:UnicodeScalar = " "
    private var ident:UnicodeScalar = " "
    private var string:String = ""
    private var intValue:Int = 0
    private var floatValue:Float = 0
    
    // Array of tokens and current token index
    private var allTokens:[Token] = []
    private var tokenIndex:Int = 0
    
    init(input: String) {
        self.input = Array(input.utf16)
    }
    
    func scan() {
        self.fetchAllTokens()
    }
    
    // Creates all tokens in input
    private func fetchAllTokens() {
        var tmpToken = Token.emptyToken(0)
        
        repeat {
            tmpToken = intGetToken()
            allTokens.append(tmpToken)
        }
        while tmpToken.type != .none
        
        print("Scanning completed")
    }
    
    // Gets next character in input
    private func get() -> UnicodeScalar {
        if inputIndex > input.count-1 {
            return UnicodeScalar(1)
        }
        
        let tmp = UnicodeScalar(input[inputIndex])!
        inputIndex += 1
        return tmp
    }
    
    // Fetches character in input and does not
    private func peek() -> UnicodeScalar {
        if inputIndex > input.count-1 {
            return UnicodeScalar(1)
        }
        
        let tmp = UnicodeScalar(input[inputIndex])!
        return tmp
    }
    
    // Gets number as string from index to first non-number character (Continues if '.' is met)
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
        
        return tmp
    }
    
    // Does string contain '.'
    private func isFloating(test: String) -> Bool {
        return test.contains(".")
    }
    
    // Fetches string from current char, allows characters allowed in identifiers
    // Should only be used for identifiers (Strings are handled in a dedicated function)
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
        
        // Clean
        // TODO: I'm not sure what this does.
        tmp = tmp.replacingOccurrences(of: "'", with: "Q") // SHould be done at code-generation, but is here temporary
        
        return tmp
    }
    
    private func getCharLiteralContent() -> String {
        char = get()
        return String(char)
    }
    
    // Fetches string literal content. Continues until '"'(quote) is met
    private func getStringLiteralContent() -> String {
        var stringContent = ""
        
        char = get()
        var escape = false
        while char != "\"" {
            
            if char == "\\" {
                escape = true
            }
            
            stringContent.append(Character(char))
            char = get()
            
            if escape == true {
                stringContent.append(Character(char))
                char = get()
                
                escape = false
            }
            
            if char == "\\" {
                escape = true
            }
            
            // Error
            if char == UnicodeScalar(1) {
                if let owner = self.owner {
                    owner.error("Error while scanning string literal")
                }
                break
            }
        }
        
        return stringContent
    }
    
    // Continues until newline. Used to ignore from # newline.
    func removeComment() {
        while char != "\n" {
            char = get()
            
            if char == UnicodeScalar(1) {
                if let owner = self.owner {
                    owner.error("Error while scanning comment")
                }
                break
            }
        }
    }
    
    
    // Returns token from string. Determines type, ex. 'type' becomes .keyword_type and so on (See TokenType)
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
            
            case "type":
                type = .keyword_type
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
            
            case "lambda":
                type = .keyword_lambda
            break
            /*
            case "null":
                type = .keyword_null
            break
            */
            default:
                type = .string
            break
        }
        
        return Token(cont: string, type: type, charIndex: inputIndex)
    }
    

    // Returns a token and increments tokenIndex
    func getToken() -> Token {
        if tokenIndex > allTokens.count-1 {
            return Token.emptyToken(-1)
        }
        
        let token = allTokens[tokenIndex]
        tokenIndex += 1
        
        return token
    }

    // Peeks 'num' from tokenIndex in tokens (Default is 0, which is the current token)
    func peekToken(num: Int = 0) -> Token {
        if tokenIndex+num > allTokens.count-1 {
            return Token.emptyToken(-1)
        }
        
        let token = allTokens[tokenIndex+num]
        return token
    }
    
    // Determines next token. Used internally, thus 'int'.
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
                
                token = Token(cont: intS, type: .number, charIndex: inputIndex)
                token.floatValue = floatValue
            }
            else {
                intValue = Int(intS)!
                
                token = Token(cont: intS, type: .number, charIndex: inputIndex)
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
                
                if char == ">" { // returns
                    token = Token(cont: ">", type: .returns, charIndex: inputIndex)
                }
                else { // I en expression
                    inputIndex -= 1
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
                let tmp = get()
                
                if tmp == "+" { // Array append
                    token = Token(cont: "++", type: .op, charIndex: inputIndex)
                }
                else {
                    inputIndex -= 1
                    token = Token(cont: "+", type: .op, charIndex: inputIndex)
                }
                break
                
            case "*":
                token = Token(cont: "*", type: .op, charIndex: inputIndex)
                break
                
            case "%":
                token = Token(cont: "%", type: .op, charIndex: inputIndex)
            break
                
            case "/":
                token = Token(cont: "/", type: .op, charIndex: inputIndex)
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
                    token = Token(cont: "!", type: .negate, charIndex: inputIndex)
                }
            break
                
            case "\"":
                let stringLit = getStringLiteralContent()
                token = Token(cont: stringLit, type: .stringLiteral, charIndex: inputIndex)
            break
                
            case "'":
                let charLit = getCharLiteralContent()
                char = get() // '
                token = Token(cont: charLit, type: .char, charIndex: inputIndex)
            break
                
            case ".":
                // Test for single dot, or variadic function
                token = Token(cont: ".", type: .op, charIndex: inputIndex)
            break
                
            case "#":
                removeComment()
                token = intGetToken()
            break
                
            default:
                if let owner = self.owner {
                    owner.error("Unknown symbol: '\(char)'.")
                }
                
                token = Token.emptyToken(inputIndex)
                break
            }
        }
        
        return token
    }
}
