//
//  KeychainError.swift
//
//
//  Created by Oscar Cardona on 17/1/21.
//  Copyright © 2021 Cardona.tv. All rights reserved.


import Foundation

public enum KeychainError: Error {
    case retrievingSavedData(msg: String)
    case storeData(msg: String)
}

extension KeychainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .retrievingSavedData(let msg):
            return NSLocalizedString("[SKError] Saved Data Error, with msg: \(msg).", comment: "Saved data")
        case .storeData(let msg):
            return NSLocalizedString("[SKError] Store Data Error, with msg: \(msg).", comment: "Store data")
        }
    }
}
