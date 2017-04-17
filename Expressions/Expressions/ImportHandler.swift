//
//  ImportHandler.swift
//  Expressions
//
//  Created by Christian Lundtofte on 17/04/2017.
//  Copyright © 2017 Christian Lundtofte. All rights reserved.
//

import Foundation

class ImportHandler {
    static var importedFiles:[String] = []
    var source:String!
    
    init(source: String) {
        self.source = source
    }
    
    // Handles all imports
    func doImports() -> String {
        let imports = matches(for: "import\\s\"(.*)\"", in: source)
        
        if imports.count == 0 { // Bail early
            return self.source
        }
        
        // Iterate all imports and insert
        for importStatement in imports {
            var name = matches(for: "\"(.*)\"", in: importStatement)[0]
            name = name.replacingOccurrences(of: "\"", with: "")
            
            // Ignore files that are already implemented
            if ImportHandler.importedFiles.contains(name) {
                continue;
            }
            ImportHandler.importedFiles.append(name)
            
            // Does file exist?
            if(!FileManager.default.fileExists(atPath: name)) {
                let err = CompilerError(reason: "Import file '"+name+"' not found!", phase: .Pre)
                ErrorHandler.shared.errors.append(err)
                break
            }
            
            // Read file and insert contents into source
            do {
                let cont = try String(contentsOfFile: name)
                
                // Replace import statement with contents of file
                source = source.replacingOccurrences(of: importStatement, with: cont)
                
                // Recursively check for other imports
                let recursiveHandler = ImportHandler(source: source)
                source = recursiveHandler.doImports()
            }
            catch {
                let err = CompilerError(reason: "Error reading import file '"+name+"'!", phase: .Pre)
                ErrorHandler.shared.errors.append(err)
                break
            }
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
