//
//  LocalService.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public enum LocalError: Error {
    case fileNotFound(String?)
    case cancelled
    case generic(Error)
}

public protocol LocalService {
    typealias CompletionHandler = (Result<Data?, LocalError>) -> Void

    func request(_ name: String?,
                 completion: @escaping CompletionHandler)
}

// MARK: - Implementation
public final class DefaultLocalService: LocalService {

    public init() {}

    public func request(_ name: String?, completion: @escaping CompletionHandler) {
        guard let fileName = name else {
            completion(.failure(LocalError.fileNotFound(name)))
            return
        }
        if let path = Bundle.main.url(forResource: fileName, withExtension: "plist") {
            do {
                let data = try Data(contentsOf: path)
                SKLogger.shared.log(msg: "open file: \(fileName)", group: .filesystem, severity: .info)
                completion(.success(data))
            } catch let error {
                SKLogger.shared.log(error: error, endpoint: nil, data: nil, group: .filesystem)
                let localError = LocalError.generic(error)
                completion(.failure(localError))
            }
        } else {
            let error = LocalError.fileNotFound(fileName)
            SKLogger.shared.log(error: error, endpoint: nil, data: nil, group: .filesystem)
            completion(.failure(error))
        }
    }
}
