//
//  File.swift
//  
//
//  Created by Oscar Cardona on 14/11/21.
//

import Foundation

public enum SKError: Error {
    case parseError(msg: String)
    case config(msg: String)
    case localServiceFailure(msg: String)
    case serviceTimeout
    case nonAuthorized
    case userNotVerified
    case accessDenied
    case notFound
    case noReponse
    case parsing
    case networkFailure(msg: String)
    case badPassword
    case badRequest
    case notConnectedToInternet
    case internalServerError
}

extension SKError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parseError(let msg):
            return NSLocalizedString("[CFError] Parse Error, with msg: \(msg).", comment: "Parse error")
        case .config(let msg):
            return NSLocalizedString("[CFError] Config Error, with msg: \(msg).", comment: "Config error")
        case .localServiceFailure(let msg):
            return NSLocalizedString("[CFError] Local Error with msg: \(msg).", comment: "Locale error")
        case .serviceTimeout:
            return NSLocalizedString("[CFError] Service timeout.", comment: "Timeout error")
        case .nonAuthorized:
            return NSLocalizedString("[CFError] Non Authorized", comment: "Server error")
        case .userNotVerified:
            return NSLocalizedString("[CFError] User Not Verified", comment: "Server error")
        case .accessDenied:
            return NSLocalizedString("[CFError] Access Denied", comment: "Server error")
        case .notFound:
            return NSLocalizedString("[CFError] Not Found", comment: "Server error")
        case .noReponse:
            return NSLocalizedString("[CFError] No Response", comment: "Server error")
        case .parsing:
            return NSLocalizedString("[CFError] Bad Parsing", comment: "Server error")
        case .networkFailure(let msg):
            return NSLocalizedString("[CFError] Network: \(msg)", comment: "Server error")
        case .badPassword:
            return NSLocalizedString("[CFError] Bad Password", comment: "Server error")
        case .notConnectedToInternet:
            return NSLocalizedString("[CFError] The device is not connected to Internet", comment: "Bad Network")
        case .badRequest:
            return NSLocalizedString("[CFError] Bad Request", comment: "Bad Network")
        case .internalServerError:
            return NSLocalizedString("[CFError] Internal Server Error", comment: "Server Error")
        }
    }
}
