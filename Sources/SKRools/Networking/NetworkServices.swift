//
//  NetworkServices.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
//

import Foundation

public enum LoadingStatus {
    case start
    case stop
}

public enum NetworkError: Error {
    case error(statusCode: Int, data: Data?, endpoint: String?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
    case noData
}

public protocol NetworkCancellable: Cancellable {
    func cancel()
}

extension URLSessionTask: NetworkCancellable { }

public protocol NetworkService {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable?
}

public protocol NetworkSessionManager {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable
}


// MARK: - Implementation
public final class DefaultNetworkService {
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: Logger
    
    public init(config: NetworkConfigurable = ApiDataNetworkConfig(),
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
                logger: Logger = DefaultLogger()) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }
    
    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            
            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data, endpoint: request.url?.relativeString)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error, group: .networking)
                completion(.failure(error))
                
            } else if let response = response as? HTTPURLResponse,
                      response.statusCode < 600,
                      response.statusCode >= 400 {
                let error: NetworkError = .error(statusCode: response.statusCode, data: data, endpoint: request.url?.relativeString)
                self.logger.log(error: error, group: .networking)
                completion(.failure(error))
            } else {
                
                self.logger.log(response: response, data: data, error: requestError, request: request, severity: .info)
                if let data = data {
                    self.logger.log(response: response, responseData: data)
                    completion(.success(data))
                } else {
                    let error: NetworkError = .noData
                    self.logger.log(error: error, group: .networking)
                    completion(.success(data))
                }
            }
        }
        
        logger.log(request: request, group: .networking, severity: .info)
        
        return sessionDataTask
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    public func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.urlGeneration))
            return nil
        }
    }
}

public class NetworkTask: NetworkCancellable {
    var dataRequest: URLSessionDataTask?
    public init(dataRequest: URLSessionDataTask?) {
        self.dataRequest = dataRequest
    }
    public func cancel() {
        dataRequest?.cancel()
    }
}

public class DefaultNetworkSessionManager: NetworkSessionManager {
    public init() {}
    public func request(_ request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        
        return task
    }
}

// MARK: - NetworkError extension

extension NetworkError {
    public var isNotFoundError: Bool { return hasStatusCode(404) }
    public var isNonAuthorizedError: Bool { return hasStatusCode(401) }
    public var isInvalidGrantError: Bool { return hasStatusCode(400) }
    public var isAccessDeniedError: Bool { return hasStatusCode(403) }
    
    public func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _, _):
            return code == codeError
        default: return false
        }
    }
}
