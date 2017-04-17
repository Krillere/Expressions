//
//  ImportHandler.swift
//  Expressions
//
//  Created by Christian Lundtofte on 17/04/2017.
//  Copyright © 2017 Christian Lundtofte. All rights reserved.
//

import Foundation

class ImportHandler {
    var source:String!
    
    init(source: String) {
        self.source = source
    }
    
    // Handles all imports
    func doImports() -> String {
        let imports = matches(for: "import\\s\"(.*)\"", in: source)
        for importStatement in imports {
            var name = matches(for: "\"(.*)\"", in: importStatement)[0]
            name = name.replacingOccurrences(of: "\"", with: "")
            
            // Does file exist?
            if(!FileManager.default.fileExists(atPath: name)) {
                let err = CompilerError(reason: "Import file '"+name+"' not found!", phase: .Pre)
                ErrorHandler.shared.errors.append(err)
                break
            }
            
            // Read file
            do {
                let cont = try String(contentsOfFile: name)
                
            }
            catch {
                let err = CompilerError(reason: "Error reading import file '"+name+"'!", phase: .Pre)
                ErrorHandler.shared.errors.append(err)
                break
            }
            
            // Remove the import statement so that scanner and parser won't see it!
            source = source.replacingOccurrences(of: importStatement, with: "")
        }
        
        
        return source
    }
    
    // Finds matches
    // http://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
