//
//  File.swift
//  
//
//  Created by Oscar Cardona on 29/02/2020.
//

import Foundation
public enum LocalError: Error {
    case fileNotFound(String?)
    case cancelled
    case generic(Error)
}

public protocol LocalService {
    typealias CompletionHandler = (Result<Data?, LocalError>) -> Void

    func request(_ jsonName: String?,
                 completion: @escaping CompletionHandler)
}

// MARK: - Implementation
public final class DefaultLocalService: LocalService {
    private let logger: NetworkErrorLogger
    private let bundle: Bundle

    public init(logger: NetworkErrorLogger = DefaultNetworkErrorLogger(),
                bundle: Bundle = Bundle.main) {
        self.logger = logger
        self.bundle = bundle
    }

    public func request(_ jsonName: String?, completion: @escaping CompletionHandler) {
        guard let name = jsonName else {
            completion(.failure(LocalError.fileNotFound(jsonName)))
            return
        }
        if let path = bundle.path(forResource: name, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                logger.log(responseData: data, response: nil)
                completion(.success(data))
            } catch let error {
                logger.log(error: error)
                let localError = LocalError.generic(error)
                completion(.failure(localError))
            }
        } else {
            let error = LocalError.fileNotFound(jsonName)
            completion(.failure(error))
        }
    }
}
