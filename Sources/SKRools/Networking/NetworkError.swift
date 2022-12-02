//
//  NetworkError.swift
//  
//
//  Created by Oscar Cardona on 19/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public enum NetworkError: Error {
    case unknown
    case notConnectedToInternet
    // 400
    case badRequest
    // 401
    case unauthorized
    // 402
    case paymentRequired
    // 403
    case forbidden
    // 404
    case notFound
    // 405
    case methodNotAllowed
    // 406
    case notAcceptable
    // 407
    case proxyAuthenticationRequired
    // 408
    case requestTimeout
    // 500
    case internalServerError
    
    public var dataTransferError: DataTransferError {
        switch self {
        case .unknown:
            return .internalServerError
        case .notConnectedToInternet:
            return .notConnectedToInternet
        case .badRequest:
            return .badRequest
        case .unauthorized, .paymentRequired, .forbidden, .notAcceptable, .proxyAuthenticationRequired:
            return .accessDenied
        case .notFound:
            return .notFound
        case .methodNotAllowed:
            return .methodNotAllowed
        case .requestTimeout:
            return .timedOut
        case .internalServerError:
            return .internalServerError
        }
    }
}
