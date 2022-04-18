//
//  NetworkServices.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public protocol NetworkCancellable: Cancellable {
    func cancel()
}

extension URLSessionTask: NetworkCancellable { }

public protocol NetworkService {
    typealias CompletionHandler = (Result<DataTransferModel?, NetworkError>) -> Void
    
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
    
    public init(config: NetworkConfigurable = ApiDataNetworkConfig(),
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager()) {
        self.sessionManager = sessionManager
        self.config = config
    }
    
    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in
            
            if let requestError = requestError {
                var code: Int
                if let response = response as? HTTPURLResponse {
                    code = response.statusCode
                } else {
                    code = (requestError as NSError).code
                }
                let error = NetworkError.error(code: code, data: data, endpoint: request.url?.relativeString)
                SKLogger.shared.log(error: error, group: .networking)
                completion(.failure(error))
                
            } else if let response = response as? HTTPURLResponse,
                      response.statusCode < 600,
                      response.statusCode >= 400 {
                let error = NetworkError.error(code: response.statusCode, data: data, endpoint: request.url?.relativeString)
                SKLogger.shared.log(error: error, group: .networking)
                completion(.failure(error))
            } else {
                
                if let data = data,
                   let response = response as? HTTPURLResponse {
                    SKLogger.shared.log(response: response, responseData: data)
                    let dataTransferModel = DataTransferModel(data: data, code: response.statusCode)
                    completion(.success(dataTransferModel))
                } else {
                    let error = NetworkError.emptyDataReceived
                    let resp = response as? HTTPURLResponse
                    let dataTransferModel = DataTransferModel(data: data ?? Data(), code: resp?.statusCode ?? 9999)
                    SKLogger.shared.log(error: error, group: .networking)
                    completion(.success(dataTransferModel))
                }
                SKLogger.shared.log(response: response, data: data, error: requestError, request: request, severity: .info)
            }
        }
        
        SKLogger.shared.log(request: request, group: .networking, severity: .info)
        
        return sessionDataTask
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

public class DefaultNetworkSessionManager: NSObject, NetworkSessionManager, URLSessionTaskDelegate {
    public override init() {super.init()}
    public func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        if #available(iOS 15.0, *) { task.delegate = self }
        task.resume()
        
        return task
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // TODO: Enable SSL Check
        completionHandler(.performDefaultHandling, nil)
    }
}
