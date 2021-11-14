//
//  File.swift
//  
//
//  Created by Oscar Cardona on 14/11/21.
//

import Foundation

public enum SKError: Error {
    case serviceError(code: String, msg: String)
    case parseError(msg: String)
    case logText(text: String)
    case logError(error: Error)
}

extension SKError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .parseError(let msg):
            return NSLocalizedString("[SKError] Parse Error, with msg: \(msg).", comment: "Parse error")
        case .serviceError(let code, let msg):
            return NSLocalizedString("[SKError] Service Error, with msg: \(msg) code: \(code)", comment: "Service error")
        case .logText(let text):
            return NSLocalizedString("[SKError] \(text).", comment: "debug")
        case .logError(let error):
            return NSLocalizedString("[SKError] \(error.localizedDescription).", comment: "error")
        }
    }
}
