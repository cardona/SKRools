//
//  File.swift
//  
//
//  Created by Oscar Cardona on 19/3/22.
//

import Foundation

public enum NetworkError: Error {
    case error(code: Int, data: Data?, endpoint: String?)
    case emptyDataReceived
    case urlGeneration
    
    
    public var dataTransferError: DataTransferError {
        switch self {
        case .emptyDataReceived:
            return .emptyDataReceived
        case .urlGeneration:
            return .urlGeneration
        case .error(let code, let data, let endpoint):
            if let err = resolveError(code: code) {
                return err
            } else {
                let details = String(data: data ?? Data(), encoding: .utf8) ?? "nil"
                let url = endpoint ?? "nil"
                return .networkError(code: code, msg: "Unknown error: \(details) - \(url)")
            }
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
        default:
            return nil
        }
    }
}
