//
//  NetworkConfigurableMock.swift
//  
//
//  Created by Oscar Cardona on 24/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

@testable import SKRools

class NetworkConfigurableMock: NetworkConfigurable {
    var baseURL: String = "https://mock.com"
    var headers: [String: String] = [:]
    var queryParameters: [String: String] = [:]
}
