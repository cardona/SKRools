//
//  NetworkSessionManagerMock.swift
//  
//
//  Created by Oscar Cardona on 24/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation
@testable import SKRools

struct NetworkSessionManagerMock: NetworkSessionManager {

    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        completion(data, response, error)
        return NetworkTask(dataRequest: nil)
    }
    
}
