//
//  NetworkError.swift
//  
//
//  Created by Oscar Cardona on 19/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public enum NetworkError: Error {
    case error(code: Int, data: Data?, endpoint: String?)
    case urlGeneration
    case cancelled
    case notConnectedToInternet
    case requestError
    
    
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
        case .error(let code, let data, let endpoint):
            return .network(error: self)
//            if let err = resolveError(code: code) {
//                return err
//            } else {
//                let details = String(data: data ?? Data(), encoding: .utf8) ?? "nil"
//                let url = endpoint ?? "nil"
//                return .network(code: code, msg: "Unknown error: \(details) - \(url)")
//            }
        }
    }
    
    private func resolveError(code: Int) -> DataTransferError? {
        let code = URLError.Code(rawValue: code)
        switch code {
        case .notConnectedToInternet:
            return .notConnectedToInternet
        case .cancelled:
            return .cancelled
        case .timedOut:
            return .timedOut
        case .unsupportedURL:
            return .urlGeneration
        default:
            return nil
        }
    }
}
