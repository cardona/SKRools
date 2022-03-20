//
//  File.swift
//  
//
//  Created by Oscar Cardona on 19/3/22.
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
    case networkError(code: Int, msg: String)
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
        case .networkError(let code, let msg):
            switch code {
            case 400:
                return.badRequest
            case 401:
                return .nonAuthorized
            case 403:
                return .accessDenied
            case 404:
                return .notFound
            case 405:
                return .nonAuthorized
            case 408:
                return .serviceTimeout
            case 500:
                return .internalServerError
            default:
                return .networkFailure(msg: msg)
            }
        case .accessDenied:
            return .accessDenied
        }
    }
}
