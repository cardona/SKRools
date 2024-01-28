//
//  SKRoolsConfig.swift
//
//
//  Created by Oscar Cardona on 21/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

/// `SKRoolsConfig` is a singleton class designed to manage and provide centralized access
/// to application-wide configurations. It offers separate modules for network and logger configurations.
/// Use the shared instance to configure and retrieve settings throughout the application.
///
/// Usage:
/// ```
/// AppConfiguration.shared.networkBaseURL = "https://api.example.com"
/// AppConfiguration.shared.loggerDebugGroups = [.networking, .secureEnclave, .system ....]
/// ```
///
/// - Note: The class is thread-safe and can be accessed from multiple threads.
public final class SKRoolsConfig {
    public static let shared = SKRoolsConfig()
    
    // Network Configuration
    private struct NetworkConfig {
        var baseURL = ""
        var publicApiKey = ""
        var privateApiKey = ""
        var certificate = ""
    }
    
    private var networkConfig = NetworkConfig()
    
    // Logger Configuration
    private struct LoggerConfig {
        var debugGroups: [DebugGroup] = [.networking]
    }
    
    private var loggerConfig = LoggerConfig()
    
    // Private initializer to prevent external instantiation.
    private init() {}
    
    /// Network base URL. Used to configure the base URL for network requests.
    public var networkBaseURL: String {
        get { networkConfig.baseURL }
        set { networkConfig.baseURL = newValue }
    }
    
    /// Public API key. Used for identifying the client in network requests.
    public var networkPublicApiKey: String {
        get { networkConfig.publicApiKey }
        set { networkConfig.publicApiKey = newValue }
    }
    
    /// Private API key. Used for secure operations and authentication.
    /// - Warning: Keep this key secure and avoid exposing it in logs or UI.
    public var networkPrivateApiKey: String {
        get { networkConfig.privateApiKey }
        set { networkConfig.privateApiKey = newValue }
    }
    
    /// SSL certificate string. Used for network security.
    public var networkCertificate: String {
        get { networkConfig.certificate }
        set { networkConfig.certificate = newValue }
    }
    
    /// Array of `DebugGroup` for logger configuration.
    /// Use this to specify which debugging groups should be active.
    public var loggerDebugGroups: [DebugGroup] {
        get { loggerConfig.debugGroups }
        set { loggerConfig.debugGroups = newValue }
    }
}
