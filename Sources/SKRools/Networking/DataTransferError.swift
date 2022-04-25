//
//  DataTransferError.swift
//  
//
//  Created by Oscar Cardona on 19/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public enum DataTransferError: Error {
    case localServiceFailure(msg: String)
    case notConnectedToInternet
    case cancelled
    case urlGeneration
    case emptyDataReceived
    case timedOut
    case accessDenied
    case network(error: NetworkError)
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
        case .network(let error):
            switch error {
            case .error(let code, let data, let endpoint):
                return.networkFailure(msg: "code")
            case .urlGeneration:
                return .badRequest
            case .cancelled:
                return .serviceFailure(msg: "cancel")
            case .notConnectedToInternet:
                return .notConnectedToInternet
            case .requestError:
                return .badRequest
            }
        case .accessDenied:
            return .accessDenied
        }
    }
}

extension DataTransferError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .localServiceFailure(let msg):
            return ""
        case .notConnectedToInternet:
            return ""
        case .cancelled:
            return ""
        case .urlGeneration:
            return "Problems generating the url, the request has not been made"
        case .emptyDataReceived:
            return ""
        case .timedOut:
            return "Service timeout"
        case .accessDenied:
            return "Access Denied"
        case .networkError(let code, let msg):
            return ""
        case .noResponse:
            return "No Response"
        case .parsing(let error):
            return "Parsion error on: \(error)"
        }
    }
}
