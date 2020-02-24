//
//  File.swift
//  
//
//  Created by Oscar Cardona on 24/02/2020.
//

import Foundation
@testable import SKRools

class NetworkConfigurableMock: NetworkConfigurable {
    var baseURL: URL = URL(string: "https://mock.test.com")!
    var headers: [String: String] = [:]
    var queryParameters: [String: String] = [:]
}
