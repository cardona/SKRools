//
//  LocalService.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
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
    private let logger: Logger

    public init(logger: Logger = DefaultLogger()) {
        self.logger = logger
    }

    public func request(_ name: String?, completion: @escaping CompletionHandler) {
        guard let fileName = name else {
            completion(.failure(LocalError.fileNotFound(name)))
            return
        }
        if let path = Bundle.main.url(forResource: fileName, withExtension: "plist") {
            do {
                let data = try Data(contentsOf: path)
                logger.log(msg: "open file: \(fileName)", group: .filesystem, severity: .info)
                completion(.success(data))
            } catch let error {
                logger.log(error: error, group: .filesystem)
                let localError = LocalError.generic(error)
                completion(.failure(localError))
            }
        } else {
            let error = LocalError.fileNotFound(fileName)
            logger.log(error: error, group: .filesystem)
            completion(.failure(error))
        }
    }
}
