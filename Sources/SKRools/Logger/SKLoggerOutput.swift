//
//  SKLoggerLogOutput.swift
//
//
//  Created by Oscar Cardona on 28/1/24.
//  Copyright © 2024 Cardona.tv. All rights reserved.
//

import Foundation

/// A protocol defining the requirements for log output destinations used by `SKLogger`.
///
/// The primary use of this protocol is to enable dependency injection for unit testing,
/// allowing for the interception and verification of log messages.
///
public protocol SKLoggerLogOutput {
    func print(_ message: String)
}

/// The default log output class that prints log messages to the console.
/// Utilizes Swift's standard `print` function for output.
///
/// This class serves as the default implementation of `SKLoggerLogOutput`,
/// and it can be replaced with custom implementations if needed.
class ConsoleLogOutput: SKLoggerLogOutput {
    func print(_ message: String) {
        Swift.print(message)
    }
}
