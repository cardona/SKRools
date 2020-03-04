//
//  NetworkServices.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 14/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation
import Alamofire

public enum LoadingStatus {
    case start
    case stop
}

public enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
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
                 completion: @escaping CompletionHandler) -> NetworkTask
}

public protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

// MARK: - Implementation
public final class DefaultNetworkService {
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger

    public init(config: NetworkConfigurable,
                sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
                logger: NetworkErrorLogger = DefaultNetworkErrorLogger()) {
        self.sessionManager = sessionManager
        self.config = config
        self.logger = logger
    }

    private func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        let sessionDataTask = sessionManager.request(request) { data, response, requestError in

            if let requestError = requestError {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }

                self.logger.log(error: error)
                completion(.failure(error))
            } else {
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }

        logger.log(request: request)

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

    private func localRequest(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
          let sessionDataTask = sessionManager.request(request) { data, response, requestError in

              if let requestError = requestError {
                  var error: NetworkError
                  if let response = response as? HTTPURLResponse {
                      error = .error(statusCode: response.statusCode, data: data)
                  } else {
                      error = self.resolve(error: requestError)
                  }

                  self.logger.log(error: error)
                  completion(.failure(error))
              } else {
                  self.logger.log(responseData: data, response: response)
                  completion(.success(data))
              }
          }

          logger.log(request: request)

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
    var dataRequest: DataRequest?
    public init(dataRequest: DataRequest?) {
        self.dataRequest = dataRequest
    }
    public func cancel() {
        dataRequest?.cancel()
    }
}

public class DefaultNetworkSessionManager: NetworkSessionManager {
    public init() {}
    public func request(_ request: URLRequest,
                        completion: @escaping CompletionHandler) -> NetworkTask {


        let url = request.url?.absoluteString ?? ""
        let method = HTTPMethod.get
        let parameters = request.allHTTPHeaderFields
        let headers =  request.headers
        let task = AF.request(url,
                   method: method,
                   parameters: parameters,
                   encoding: URLEncoding(),
                   headers: headers,
            interceptor: nil).response(completionHandler: { response in
                switch response.result {
                case .success(let data):
                    completion(data, response.response, nil)
                case .failure(let error):
                    completion(nil, response.response, error)
                }
            })

        return NetworkTask(dataRequest: task)
    }
}

// MARK: - Logger

public final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    public init() { }

    public func log(request: URLRequest) {
        #if DEBUG
        print("-------------")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            print("body: \(String(describing: result))")
        }
        if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            print("body: \(String(describing: resultString))")
        }
        #endif
    }

    public func log(responseData data: Data?, response: URLResponse?) {
        #if DEBUG
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("responseData: \(String(describing: dataDict))")
        } else if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
            print("responseData: \(String(describing: dataDict))")
        }
        #endif
    }

    public func log(error: Error) {
        #if DEBUG
        print("\(error)")
        #endif
    }
}

// MARK: - NetworkError extension

extension NetworkError {
    public var isNotFoundError: Bool { return hasStatusCode(404) }

    public func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _):
            return code == codeError
        default: return false
        }
    }
}
