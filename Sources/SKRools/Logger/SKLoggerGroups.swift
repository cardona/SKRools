//
//  SKLoggerGroups.swift
//
//
//  Created by Oscar on 28/1/24.
//  Copyright © 2024 Cardona.tv. All rights reserved.
//

import Foundation

public enum DebugSeverity: Int {
    case error
    case info
}

public enum DebugGroup: String {
    case networking
    case keychain
    case parse
    case secureEnclave
    case configuration
    case system
    case filesystem
    case token
    case alert
    case networkingHeaders
    case networkingBody
    case debug
    case database
}
