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
    case badRequest
    case emptyDataReceived
    case timedOut
    case accessDenied
    case forbidden
    case unauthorized
    case noResponse
    case parsing(Error)
    case notFound
    case internalServerError
    case methodNotAllowed

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
        case .badRequest:
            return .badRequest
        case .emptyDataReceived:
            return .networkFailure(msg: self.localizedDescription)
        case .timedOut:
            return .serviceTimeout
        case .accessDenied:
            return .accessDenied
        case .notFound:
            return .notFound
        case .forbidden:
            return .accessDenied
        case .unauthorized:
            return .accessDenied
        case .internalServerError:
            return .internalServerError
        case .methodNotAllowed:
            return .serviceFailure(msg: "Method Not Allowed")
        }
    }
}
