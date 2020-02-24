//
//  SKRError.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 23/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation

public enum SKRError: Error {
    case dataTransfer(msg: String)
    case loadingView(msg: String)
}

extension SKRError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataTransfer(let msg):
            return NSLocalizedString("Data Transfer Error: \(msg)", comment: "[Custom Error]")
        case .loadingView(let msg):
            return NSLocalizedString("Loading view Error: \(msg)", comment: "[Custom Error]")
        }
    }
}
