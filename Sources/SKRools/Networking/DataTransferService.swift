//
//  DataTransferService.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
//

import Foundation

public enum DataTransferError: Error {
    case noResponse
    case parsing(Error)
    case networkFailure(NetworkError)
    case resolvedNetworkFailure(Error)
}

public protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, Error>) -> Void
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T
    func localRequest<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>)
    
}

public protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public final class DefaultDataTransferService {
    private let localService: LocalService
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: Logger
    
    public init(with localService: LocalService = DefaultLocalService(),
                networkService: NetworkService = DefaultNetworkService(),
                errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
                errorLogger: Logger = DefaultLogger()) {
        self.localService = localService
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DefaultDataTransferService: DataTransferService {
    
    public func request<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T {
        
        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let res: Result<T, Error> = self.decode(data: data, decoder: endpoint.responseDecoder, url: endpoint.path)
                return completion(res)
            case .failure(let error):
                let error = self.resolve(networkError: error)
                return completion(.failure(error))
            }
        }
    }

    public func localRequest<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>) {

        localService.request(endpoint.path, completion: { result  in
            switch result {
            case .success(let data):
                let result: Result<T, Error> = self.decode(data: data, decoder: endpoint.responseDecoder, url: endpoint.path)
                return completion(result)
            case .failure(let error):
                self.errorLogger.log(error: error, group: .filesystem)
                return completion(.failure(error))
            }
        })
    }

    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder, url: String) -> Result<T, Error> {
        guard let data = data else { return .failure(DataTransferError.noResponse) }
        do {
            let result: T = try decoder.decode(data)
            
            return .success(result)
        } catch {
            self.errorLogger.log(error: error, group: .networking)
            return .failure(DataTransferError.parsing(error))
        }
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        let resolvedError = self.errorResolver.resolve(error: error)
        return resolvedError is NetworkError ? .networkFailure(error) : .resolvedNetworkFailure(resolvedError)
    }
}


// MARK: - Error Resolver
public class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    public init() { }
    public func resolve(error: NetworkError) -> Error {
        return error
    }
}

// MARK: - JSON Response Decoders
public class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    public init() { }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

// MARK: - PLIST Response Decoders
public class PLISTResponseDecoder: ResponseDecoder {
    private let plistDecoder = PropertyListDecoder()
    public init() { }
    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try plistDecoder.decode(T.self, from: data)
    }
}
