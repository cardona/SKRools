//
//  DataTransferService.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
//

import Foundation

public protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
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
    
    public init(with localService: LocalService = DefaultLocalService(),
                networkService: NetworkService = DefaultNetworkService(),
                errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver()) {
        self.localService = localService
        self.networkService = networkService
        self.errorResolver = errorResolver
    }
}

extension DefaultDataTransferService: DataTransferService {
    
    public func request<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>) -> NetworkCancellable? where E.Response == T {
        
        return self.networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let dataTransfer):
                let res: Result<T, DataTransferError> = self.decode(data: dataTransfer?.data,
                                                                    decoder: endpoint.responseDecoder,
                                                                    url: endpoint.path,
                                                                    code: dataTransfer?.code ?? 200)
                return completion(res)
            case .failure(let error):
                return completion(.failure(error.dataTransferError))
            }
        }
    }

    public func localRequest<T: Decodable, E: ResponseRequestable>(with endpoint: E, completion: @escaping CompletionHandler<T>) {

        localService.request(endpoint.path, completion: { result  in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(data: data,
                                                                       decoder: endpoint.responseDecoder,
                                                                       url: endpoint.path,
                                                                       code: 200)
                return completion(result)
            case .failure(let error):
                Logger.shared.log(error: error, group: .filesystem)
                let dataTransferError = DataTransferError.localServiceFailure(msg: error.localizedDescription)
                
                return completion(.failure(dataTransferError))
            }
        })
    }

    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder, url: String, code: Int) -> Result<T, DataTransferError> {
      
        guard let data = data else { return .failure(DataTransferError.noResponse) }
       
        do {
            let result: T = try decoder.decode(data)
            
            return .success(result)
        } catch {
            Logger.shared.log(error: error, group: .networking)
            return .failure(DataTransferError.parsing(error))
        }
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