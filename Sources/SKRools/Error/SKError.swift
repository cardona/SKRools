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
    case serviceFailure(msg: String)
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
    case badAudio
    case notConnectedToInternet
    case internalServerError
    case storedData(msg: String)
    case storingData(msg: String)
    case decryptingData(msg: String)
    case encryptingData(msg: String)
    case symmetricKey(msg: String)
    case privateKey(msg: String)
    case emptyData
    case emptyHeader
    case emptyList
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
        case .decryptingData(let msg):
            return NSLocalizedString("[SKError] Decrypting Data Error, with data: \(msg).", comment: "Decryption Data")
        case .encryptingData(let msg):
            return NSLocalizedString("[SKError] Encrypting Data Error, with data: \(msg).", comment: "Encryption Data")
        case .symmetricKey(let msg):
            return NSLocalizedString("[SKError] SymetricKey Error, with data: \(msg).", comment: "SymetricKey")
        case .privateKey(let msg):
            return NSLocalizedString("[SKError] Private Key Error, with msg: \(msg).", comment: "Private Key")
        case .serviceFailure(let msg):
            return NSLocalizedString("[SKError] Service Error, with msg: \(msg).", comment: "Service Error")
        case .badAudio:
            return NSLocalizedString("[SKError] Bad Audio, Audio not loaded.", comment: "Audio Error")
        case .emptyData:
            return NSLocalizedString("[SKError] Empty Data.", comment: "Warning")
        case .emptyHeader:
            return NSLocalizedString("[SKError] Empty Header Data.", comment: "Warning")
        case .emptyList:
            return NSLocalizedString("[SKError] Empty List Data.", comment: "Warning")
        }
    }
}
