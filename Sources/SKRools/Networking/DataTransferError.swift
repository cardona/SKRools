//
//  DataTransferError.swift
//  
//
//  Created by Oscar Cardona on 19/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public enum DataTransferError: Error {
    case serviceFailure(code: Int, title: String?, detail: String?)
    case localServiceFailure(msg: String)
    case notConnectedToInternet
    case cancelled
    case urlGeneration
    case emptyDataReceived
    case timedOut
    case accessDenied
    case noResponse
    case parsing(Error)
    
    public var skError: SKError {
        switch self {
        case .noResponse:
            return .noReponse
        case .parsing(let error):
            return .parseError(msg: error.localizedDescription)
        case .localServiceFailure(let msg):
            return .localServiceFailure(msg: msg)
        case .notConnectedToInternet:
            return .notConnectedToInternet
        case .cancelled:
            return .networkFailure(msg: self.localizedDescription)
        case .urlGeneration:
            return .networkFailure(msg: self.localizedDescription)
        case .emptyDataReceived:
            return .networkFailure(msg: self.localizedDescription)
        case .timedOut:
            return .serviceTimeout
        case .accessDenied:
            return .accessDenied
        case .serviceFailure(_, let title, _):
            return .serviceFailure(msg: title ?? "unknown Error")
        }
    }
}
