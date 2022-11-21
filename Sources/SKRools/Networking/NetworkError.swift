//
//  NetworkError.swift
//  
//
//  Created by Oscar Cardona on 19/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public enum NetworkError: Error {
    case urlGeneration
    case cancelled
    case notConnectedToInternet
    case requestError
    case serviceFailure(code: Int, title: String?, detail: String?)
    case accessDenied
    case notFound
    case forbidden
    case unauthorized
    
    public var dataTransferError: DataTransferError {
        switch self {
        case .urlGeneration:
            return .urlGeneration
        case .cancelled:
            return .cancelled
        case .notConnectedToInternet:
            return .notConnectedToInternet
        case .requestError:
            return .urlGeneration
        case .serviceFailure(code: let code, title: let title, detail: let detail):
            return .serviceFailure(code: code, title: title, detail: detail)
        case .accessDenied:
            return .accessDenied
        case .notFound:
            return .noResponse
        case .forbidden:
            return .forbidden
        case .unauthorized:
            return .unauthorized
        }
    }
}
