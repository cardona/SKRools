//
//  NetworkConfigurable.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public protocol NetworkConfigurable {
    var baseURL: String { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

public struct ApiDataNetworkConfig: NetworkConfigurable {
    public let baseURL: String
    public let headers: [String: String]
    public let queryParameters: [String: String]

    public init(baseURL: String? = nil,
                headers: [String: String] = [:],
                queryParameters: [String: String] = [:]) {
        self.baseURL = baseURL ?? SKRoolsConfig.shared.networkBaseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
