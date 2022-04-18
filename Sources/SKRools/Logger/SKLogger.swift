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
}

public class SKLogger {
    public static let shared = SKLogger()
    
    private func enabledGroups() -> [DebugGroup] {
        return SKRoolsConfig.shared.debugGroups()
    }
    
    public func log(msg: String, group: DebugGroup, severity: DebugSeverity) {
        log(text: msg, group: group, severity: severity)
    }
    
    public func log(error: Error, group: DebugGroup) {
        var text = "\nERROR"
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .error(let statusCode, let data, let endpoint):
                text = """
                \(text)
                → [\(statusCode)] \(endpoint ?? "")
                
                """
                if let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        text = """
                    \(text)
                    Data:
                    \(String(decoding: jsonData, as: UTF8.self))
                    
                    """
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
                    }
                }
            default:
                text = """
                    \(text)
                    \(networkError.localizedDescription)
                    
                """
            }
            
        } else {
            text = """
                \(text)
                \(error.localizedDescription)
                
            """
        }
        
        text = """
        \(text)
        
        END ERROR
        
        """
        
        log(text: text, group: group, severity: .error)
    }
    
    public func log(request: URLRequest, group: DebugGroup, severity: DebugSeverity) {
        
        var requestText = "\nREQUEST"
        
        if let method = request.httpMethod,
           let url = request.url {
            requestText = """
            \(requestText)
            → [\(method)] \(url)
            """
        }
        
        if let fields = request.allHTTPHeaderFields,
           !fields.isEmpty,
           let headersData = try? JSONSerialization.data(withJSONObject: fields, options: .prettyPrinted) {
            requestText = """
            \(requestText)
            
            Headers:
            \(String(decoding: headersData, as: UTF8.self))
            """
        }
        
        if let httpBody = request.httpBody, let json = try? JSONSerialization.jsonObject(with: httpBody, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            var body = String(decoding: jsonData, as: UTF8.self)
            body = body.replacingOccurrences(of: "&", with: "\n")
            
            requestText = """
            \(requestText)
            
            Body:
            \(body)
            
            """
        } else if let httpBodyData = request.httpBody,
                  var body = String(data: httpBodyData, encoding: .utf8) {
            body = body.replacingOccurrences(of: "&", with: "\n")
            
            requestText = """
            \(requestText)
            
            Body:
            \(body)
            
            """
        }
        requestText = """
        \(requestText)
        
        END REQUEST
        
        """
        
        log(text: requestText, group: group, severity: severity)
    }
    
    public func log(response: URLResponse?, data: Data?, error: Error?, request: URLRequest, severity: DebugSeverity) {
        
        var text = "\nRESPONSE"
        
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
        
        if let response = response as? HTTPURLResponse,
           response.statusCode < 600,
           response.statusCode >= 400 {
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    text = """
                \(text)
                Data:
                \(String(decoding: jsonData, as: UTF8.self))
                
                """
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
                }
            }
        }
        
        text = """
        \(text)
        
        END RESPONSE
        
        """
        if let response = response as? HTTPURLResponse,
           response.statusCode < 600,
           response.statusCode >= 400 {
            log(text: text, group: .networking, severity: .error)
        } else {
            log(text: text, group: .networking, severity: severity)
        }
    }
    
    public func log(response: URLResponse?, responseData data: Data?) {
        guard let data = data else { return }
        var text = "\n"
        if let response = response as? HTTPURLResponse,
           let url = response.url {
            text = """
            \(text)
            → \(url)
            
            """
        }
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            text = """
            \(text)
            Data:
            \(String(decoding: jsonData, as: UTF8.self))
            
            """
            if let response = response as? HTTPURLResponse,
               response.statusCode < 600,
               response.statusCode >= 400 {
                log(text: text, group: .parse, severity: .error)
            } else {
                log(text: text, group: .parse, severity: .info)
            }
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
