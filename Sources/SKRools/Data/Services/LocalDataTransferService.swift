//
//  File.swift
//  
//
//  Created by Oscar Cardona on 29/02/2020.
//

import Foundation

public enum LocalDataTransferError: Error {
    case noResponse
    case parsing(Error)
}

public protocol LocalDataTransferService {
    typealias CompletionHandler<T> = (Result<T, Error>) -> Void

    func localRequest<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                            completion: @escaping CompletionHandler<T>)
}

public protocol LocalDataTransferErrorLogger {
    func log(error: Error)
}

public final class DefaultLocalDataTransferService {

    private let localService: LocalService
    private let errorLogger: DataTransferErrorLogger

    public init(with localService: LocalService,
                errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()) {
        self.localService = localService
        self.errorLogger = errorLogger
    }
}

extension DefaultLocalDataTransferService: LocalDataTransferService {

    public func localRequest<T: Decodable, E: ResponseRequestable>(with endpoint: E,
                                                                   completion: @escaping CompletionHandler<T>) {

        localService.request(endpoint.path, completion: { result  in
            switch result {
            case .success(let data):
                let result: Result<T, Error> = self.decode(data: data, decoder: endpoint.responseDecoder)
                DispatchQueue.main.async { return completion(result) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                DispatchQueue.main.async { return completion(.failure(error)) }
            }
        })
    }

    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) -> Result<T, Error> {
        do {
            guard let data = data else { return .failure(DataTransferError.noResponse) }
            let result: T = try decoder.decode(data)
            return .success(result)
        } catch {
            self.errorLogger.log(error: error)
            return .failure(DataTransferError.parsing(error))
        }
    }
}

// MARK: - Logger
public final class DefaultLocalDataTransferErrorLogger: DataTransferErrorLogger {
    public init() { }

    public func log(error: Error) {
        #if DEBUG
        print("-------------")
        print("\(error)")
        #endif
    }
}

