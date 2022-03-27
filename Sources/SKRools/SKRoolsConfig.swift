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
    private var currentBaseURL = "noURLBase!"
    private var currentLoggerGroup: [DebugGroup] = [.networking,
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
    
    func baseURL() -> String {
        return currentBaseURL
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
