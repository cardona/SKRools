//
//  SKRoolsConfig.swift
//  
//
//  Created by Oscar Cardona on 21/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public final class SKRoolsConfig {
    public static let shared = SKRoolsConfig()
    private lazy var currentBaseURL = "noURLBase!"
    private var currentApikeyPublic: String?
    private var currentApikeyPrivate: String?
    private var currentCert: String?
    private lazy var currentLoggerGroup: [DebugGroup] = [.networking,
                                                         .filesystem,
                                                         .system,
                                                         .secureEnclave,
                                                         .keychaing,
                                                         .configuration,
                                                         .token,
                                                         .parse]
    
}

// MARK: - Network Config
extension SKRoolsConfig {
    public func config(url: String) {
        currentBaseURL = url
    }
    
    public func config(apikeyPublic: String) {
        currentApikeyPublic = apikeyPublic
    }
    
    public func config(apikeyPrivate: String) {
        currentApikeyPrivate = apikeyPrivate
    }

    public func config(cert: String) {
        currentCert = cert
    }

    func baseURL() -> String {
        return currentBaseURL
    }
    
    public func apikeyPublic() -> String? {
        return currentApikeyPublic
    }
    
    public func apikeyPrivate() -> String? {
        return currentApikeyPrivate
    }

    public func cert() -> String? {
        return currentCert
    }
}

// MARK: - Logger Config
extension SKRoolsConfig {
    public func config(loggerGroups: [DebugGroup]) {
        currentLoggerGroup = loggerGroups
    }
    
    func debugGroups() -> [DebugGroup] {
        return currentLoggerGroup
    }
}
