//
//  SKLogger.swift
//  
//
//  Created by Oscar Cardona on 13/11/21.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public enum DebugSeverity: Int {
    case error
    case info
}

public enum DebugGroup: String {
    case networking
    case keychaing
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

public class SKLogger {
    public static let shared = SKLogger()
    
    private func enabledGroups() -> [DebugGroup] {
        return SKRoolsConfig.shared.debugGroups()
    }

    public func log(msg: String, group: DebugGroup, severity: DebugSeverity) {
        log(text: "\(msg)", group: group, severity: severity)
    }

    public func log(error: Error, endpoint: String?, data: Data?, group: DebugGroup) {
        var text = "\nERROR"
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .badRequest:
                text = """
                Request Failure
                \(text)
                → \(endpoint ?? "")
                
                \(error.localizedDescription)
                
                """
            case .forbidden:
                text = """
                Access Denied
                \(text)
                → \(endpoint ?? "")
                
                \(error.localizedDescription)
                
                """
            case .notConnectedToInternet:
                text = """
                Not Connected to Internet
                Check your network connection
                \(text)
                → \(endpoint ?? "")
                
                \(error.localizedDescription)
                
                """
            default:
                text = """
                    \(text)
                    \(String(describing: networkError))
                    
                """
            }
        } else {
            text = """
                \(text)
                \(String(describing: error))
                
            """
        }
        
        text = """
        \(text)
        
        END ERROR
        
        """
        
        log(text: text, group: group, severity: .error)
    }
    
    public func log(request: URLRequest, group: DebugGroup, severity: DebugSeverity) {
        
        var requestText = ""
        
        if let method = request.httpMethod,
           let url = request.url {
            requestText = """
            \(requestText)
            → [\(method)] \(url)
            """
        }
        
        if let fields = request.allHTTPHeaderFields,
           !fields.isEmpty,
           enabledGroups().contains(.networkingHeaders),
           let headersData = try? JSONSerialization.data(withJSONObject: fields, options: .prettyPrinted) {
            requestText = """
            \(requestText)
            
            Headers:
            \(String(decoding: headersData, as: UTF8.self))
            """
        }
        
        if let httpBody = request.httpBody, let json = try? JSONSerialization.jsonObject(with: httpBody, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           enabledGroups().contains(.networkingBody) {
            var body = String(decoding: jsonData, as: UTF8.self)
            body = body.replacingOccurrences(of: "&", with: "\n")
            
            requestText = """
            \(requestText)
            
            Body:
            \(body)
            
            """
        } else if let httpBodyData = request.httpBody,
                  var body = String(data: httpBodyData, encoding: .utf8),
                  enabledGroups().contains(.networkingBody) {
            body = body.replacingOccurrences(of: "&", with: "\n")
            
            requestText = """
            \(requestText)
            
            Body:
            \(body)
            
            """
        }
        requestText = """
        \(requestText)
        """
        
        log(text: requestText, group: group, severity: severity)
    }
    
    public func log(response: URLResponse?, error: Error?, request: URLRequest) {
        
        var text = ""
        
        if let response = response as? HTTPURLResponse {
            text = """
            \(text)
            → [\(response.statusCode)]
            """
        }
        
        if let url = request.url {
            text = """
            \(text) \(url)
            """
        }
        
        if let error = error {
            text = """
            \(text)
            ‼️ \(error) ‼️
            """
        }
    
        text = """
        \(text)
        """
        if let response = response as? HTTPURLResponse,
           response.statusCode < 600,
           response.statusCode >= 400 {
            log(text: text, group: .networking, severity: .error)
        } else {
            log(text: text, group: .networking, severity: .info)
        }
    }
        
    public func log(parse data: Data?, enpoint: String) {
        guard let data = data else {
            log(text: "Empty data", group: .parse, severity: .info)
            return
        }
        
        var text = "\n"
        
        text = """
            \(text)
            → \(enpoint)
            
            """
        
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            let string = String(decoding: jsonData, as: UTF8.self)
            let fixed = string.replacingOccurrences(of: "\\/", with: "/")
            text = """
            \(text)
            Data:
            \(fixed)
            
            """
            log(text: text, group: .parse, severity: .info)
        } else {
            text = """
            \(text)
            Bad Json:
            """
            if let errorText = String(data: data, encoding: .utf8) {
                text = """
                \(text)
                \(errorText)
                
                """
            }
            log(text: text, group: .parse, severity: .error)
        }
    }
}

// MARK: - Logger

private extension SKLogger {
    private func log(text: String, group: DebugGroup, severity: DebugSeverity) {

        if enabledGroups().filter({$0 == group}).first != nil {
            
            var line = addSeverityIcon(line: text, severity: severity)
            line = addGroupIcon(line: line, group: group)
            line = addDate(line: line)
#if DEBUG
            print(line)
#endif
        }
    }
    
    private func addGroupIcon(line: String, group: DebugGroup) -> String {
        var iconLine = line
        
        switch group {
        case .networking:
            iconLine = "📞 [NETWORKING] " + iconLine
        case .keychaing:
            iconLine = "📦 [KEYCHAIN] " + iconLine
        case .parse:
            iconLine = "🗒 [PARSE] " + iconLine
        case .secureEnclave:
            iconLine = "🔐 [SECURE ENCLAVE] " + iconLine
        case .configuration:
            iconLine = "⚙️ [CONFIG] " + iconLine
        case .system:
            iconLine = "📱 [SYSTEM] " + iconLine
        case .filesystem:
            iconLine = "💿 [FILESYSTEM] " + iconLine
        case .token:
            iconLine = "📝 [TOKEN MANAGER] " + iconLine
        case .alert:
            iconLine = "🚨 [ALERT] " + iconLine
        case .networkingHeaders:
            iconLine = "📃 [HEADERS] " + iconLine
        case .networkingBody:
            iconLine = "🔋 [BODY] " + iconLine
        case .debug:
            iconLine = "🪲 [DEBUG] " + iconLine
        case .database:
            iconLine = "🥫 [DATABASE] " + iconLine
        }
        
        return iconLine
    }
    
    private func addSeverityIcon(line: String, severity: DebugSeverity) -> String {
        var iconLine = line
        
        switch severity {
            
        case .error:
            iconLine = "‼️ " + iconLine + " ‼️"
        case .info:
            break
        }
        
        return iconLine
    }
    
    private func addDate(line: String) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm:ss:SSSS"
        let result = formatter.string(from: date)
        
        return "[\(result)] - \(line)"
    }
}
