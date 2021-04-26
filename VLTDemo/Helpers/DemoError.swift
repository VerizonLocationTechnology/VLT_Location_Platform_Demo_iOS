//
// DemoError.swift
//
// Created by Verizon Location Technology
// Copyright © 2021 Verizon Location Technology
//

import Foundation

/// Common struct to faciliate common error, and runtime processsing messages in the demo application.
/// Implementations:
/// Error       DemoError(file: #file, function: #function, line: #line, error: error).print()
/// Message     DemoError(file: #file, function: #function, line: #line, message: "Your Message Here").print()
public struct DemoError {
    var file: String
    var function: String
    var line: Int
    var error: Error?
    var message: String?

    func print() {
        Swift.print("\n")
        Swift.print("**********  Demo Application Messaging/Error **********")
        Swift.print("File:\(file)\nFunction: \(function)\nLine: \(line)")
        if let message = message {
            Swift.print("Message: \(message)")
        }
        if let error = error {
            Swift.print("Error: \(error)")
        }
        Swift.print("*******************************************************")
        Swift.print("\n")
    }
}
