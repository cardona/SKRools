//
//  File.swift
//  
//
//  Created by Oscar Cardona on 14/11/21.
//  Copyright © 2020 Cardona.tv. All rights reserved.
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
    case storedData(msg: String)
    case storingData(msg: String)
}

extension SKError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parseError(let msg):
            return NSLocalizedString("[SKError] Parse Error, with msg: \(msg).", comment: "Parse error")
        case .config(let msg):
            return NSLocalizedString("[SKError] Config Error, with msg: \(msg).", comment: "Config error")
        case .localServiceFailure(let msg):
            return NSLocalizedString("[SKError] Local Error with msg: \(msg).", comment: "Local Storage error")
        case .serviceTimeout:
            return NSLocalizedString("[SKError] Service timeout.", comment: "Timeout error")
        case .nonAuthorized:
            return NSLocalizedString("[SKError] Non Authorized", comment: "Server error")
        case .userNotVerified:
            return NSLocalizedString("[SKError] User Not Verified", comment: "Server error")
        case .accessDenied:
            return NSLocalizedString("[SKError] Access Denied", comment: "Server error")
        case .notFound:
            return NSLocalizedString("[SKError] Not Found", comment: "Server error")
        case .noReponse:
            return NSLocalizedString("[SKError] No Response", comment: "Server error")
        case .parsing:
            return NSLocalizedString("[SKError] Bad Parsing", comment: "Parse Error")
        case .networkFailure(let msg):
            return NSLocalizedString("[SKError] Network: \(msg)", comment: "Network Error")
        case .badPassword:
            return NSLocalizedString("[SKError] Bad Password", comment: "Server error")
        case .notConnectedToInternet:
            return NSLocalizedString("[SKError] The device is not connected to Internet", comment: "Network Error")
        case .badRequest:
            return NSLocalizedString("[SKError] Bad Request", comment: "Request Error")
        case .internalServerError:
            return NSLocalizedString("[SKError] Internal Server Error", comment: "Server Error")
        case .storedData(let msg):
            return NSLocalizedString("[SKError] Stored Data Error, with msg: \(msg).", comment: "Stored data")
        case .storingData(let msg):
            return NSLocalizedString("[SKError] Storing Data Error, with msg: \(msg).", comment: "Stored data")
        }
    }
}
