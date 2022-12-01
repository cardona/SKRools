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
    typealias CompletionHandlerImage = (Result<Data?, NetworkError>) -> Void
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable?
    func requestData(url: URL, completion: @escaping CompletionHandlerImage) -> NetworkCancellable?
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
        let sessionDataTask = sessionManager.request(request) { [weak self] data, response, requestError in
            guard let self = self else {
                SKLogger.shared.log(response: nil, error: NetworkError.badRequest, request: request)
                completion(.failure(.badRequest))
                return
            }
            if let error = requestError as? NSError {
                let networkError = self.networkErrorBy(code: error.code)
                completion(.failure(networkError))
                return
            }
            let endponit = response?.url?.absoluteString ?? ""
            if let response = response as? HTTPURLResponse,
               response.statusCode != 200 {
                
                let code = response.statusCode
                let error = self.networkErrorBy(code: code)
                SKLogger.shared.log(error: error, endpoint: endponit, data: data, group: .networking)

                completion(.failure(error))
                
            } else {
                let resp = response as? HTTPURLResponse
                let dataTransferModel = DataTransferModel(data: data ?? Data(), code: resp?.statusCode ?? 9999)
                
                SKLogger.shared.log(response: resp, error: requestError, request: request)
                
                completion(.success(dataTransferModel))
            }
        }
        
        SKLogger.shared.log(request: request, group: .networking, severity: .info)
        return sessionDataTask
    }

    private func networkErrorBy(code: Int) -> NetworkError {
        switch code {
        case -1009:
            return .notConnectedToInternet
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 402:
            return .paymentRequired
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 405:
            return .methodNotAllowed
        case 406:
            return .notAcceptable
        case 407:
            return .proxyAuthenticationRequired
        case 408:
            return .requestTimeout
        case 409..<599:
            return .internalServerError
        default:
            return .unknown
        }
    }
}

extension DefaultNetworkService: NetworkService {
    public func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            return request(request: urlRequest, completion: completion)
        } catch {
            completion(.failure(.badRequest))
            return nil
        }
    }
    
    public func requestData(url: URL, completion: @escaping CompletionHandlerImage) -> NetworkCancellable? {
        let session = URLSession(configuration: .default)
        let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
            if error == nil,
               let _ = response as? HTTPURLResponse {
                completion(.success(data))
            } else {
                completion(.failure(NetworkError.badRequest))
            }
        }
        downloadPicTask.resume()
        
        return downloadPicTask
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
        completionHandler(.performDefaultHandling, nil)
//        guard let cert = SKRoolsConfig.shared.cert() else {
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//        if #available(iOS 15.0, *) { let certificates = [Data(base64Encoded: cert, options: .ignoreUnknownCharacters)]
//
//            if let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0,
//               let trustedCertificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] {
//                let serverCertificatesData = Set(trustedCertificates.map { SecCertificateCopyData($0) as Data })
//
//                for certData in serverCertificatesData {
//                    if certificates.contains(certData) {
//                        completionHandler(.useCredential, URLCredential(trust: trust))
//                        return
//                    }
//                }
//            } else {
//                SKLogger.shared.log(msg: "SSL Cancel: Untrusted cert",
//                                    group: .networking,
//                                    severity: .error)
//                completionHandler(.cancelAuthenticationChallenge, nil)
//            }
//        }
    }
}
