//
//  File.swift
//  
//
//  Created by Oscar Cardona on 24/02/2020.
//

import Foundation
@testable import SKRools

struct NetworkSessionManagerMock: NetworkSessionManager {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?

    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable {
        completion(data, response, error)
        return URLSessionDataTask()
    }

    func request(_ request: URLRequest,
                 completion: @escaping Self.CompletionHandler) -> NetworkTask {
        completion(data, response, error)
        return NetworkTask(dataRequest: nil)
    }

}
