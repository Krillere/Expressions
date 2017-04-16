//
//  main.swift
//  Parser
//
//  Created by Christian Lundtofte on 19/10/2016.
//  Copyright © 2016 Christian Lundtofte. All rights reserved.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

ParserTables.shared.randomizeNames = false


// MARK: Functions
func main() {
    do {
        // Should we show help?
        if(args[0] == "help") {
            showHelp()
            exit(0)
        }
        
        // Arguments
        let validate = args.contains("validate")
        let run = args.contains("run")
        let runclean = args.contains("run-clean")
        
        // Read input file and compile
        let path = args[1]
        print("Trying to read and compile code at: \(path).")
        
        let cont = try String(contentsOfFile: path)
        Compiler.compile(code: cont)
        
        if validate { // Don't generate intermediate
            exit(0)
        }
        
        // Try saving it (If no name is specified, save on desktop)
        guard let intermediate = Compiler.intermediateCode else { exit(0) }
        
        do {
            var writePath = ""
            
            if args.count == 3 {
                writePath = args[2]
            }
            else {
                writePath = "intermediate.cpp"
            }
            
            try intermediate.write(toFile: writePath, atomically: true, encoding: String.Encoding.utf8)
            
            // Run?
            if run || runclean {
                print("Running: \n")
                fflush(stdout)
                let _ = shell("g++ -std=c++11 \(writePath) -o exprOut; ./exprOut")
                
                if(runclean) { // Remove everything
                    let _ = shell("rm \(writePath) && rm exprOut")
                }
            }
            else {
                print("To compile and run: g++ -std=c++11 \(writePath) -o exprOut; ./exprOut")
            }
        }
        catch {
            print("Error trying to save intermediate code: \(error)")
        }
    }
    catch {
        print("File error: \(error)")
    }
}

func showHelp() {
    print("In order to compile and save intermediate code: InputFile OutputFile(Optional) [args](Optional)")
    print("Call with 'help' to show this")
    print("Call with 'validate' to only validate code, and not generate intermediate code")
    print("Call with 'run' to generate intermediate and run once finished")
    print("Call with 'run-clean' to run once compiled and then remove intermediate and executable")
}

// From: http://stackoverflow.com/a/40102679
func shell(_ command: String) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = ["bash", "-c", command]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

// MARK: Entry point
let args = CommandLine.arguments

// Bail if no input file is specified
if args.count < 2 {
    print("Error: No input file specified.")
    showHelp()
    exit(0)
}

main()
