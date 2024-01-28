//
//  SKLogger.swift
//
//
//  Created by Oscar Cardona on 13/11/21.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation

/// A logging utility for Swift applications, `SKLogger` provides a centralized and configurable logging system.
/// It enables developers to log messages, errors, and HTTP traffic with enhanced formatting, categorization,
/// and severity levels. Ideal for both development and debugging, `SKLogger` helps in analyzing and tracking
/// application behavior efficiently.
///
/// Usage:
/// - Access the shared instance: `SKLogger.shared`
/// - Set custom log output (if needed): `logger.logOutput = CustomLogOutput()`
/// - Log messages, errors, and HTTP requests/responses with appropriate group and severity
///
/// Example:
/// ```
/// SKLogger.shared.log(msg: "User logged in", group: .system, severity: .info)
/// ```
public class SKLogger {
    /// Shared instance for global access.
    public static let shared = SKLogger()
    
    /// The output destination for the logs. By default, it uses `ConsoleLogOutput`.
    public var logOutput: SKLoggerLogOutput = ConsoleLogOutput()
    
    /// Returns the list of enabled debug groups from `SKRoolsConfig`.
    private func enabledGroups() -> [DebugGroup] {
        return SKRoolsConfig.shared.loggerDebugGroups
    }
    
    /// Logs a message with a specific debug group and severity level.
    /// - Parameters:
    ///   - msg: The message to be logged.
    ///   - group: The debug group this log belongs to.
    ///   - severity: The severity level of the log.
    public func log(msg: String, group: DebugGroup, severity: DebugSeverity) {
        guard enabledGroups().contains(group) else { return }
        let formattedMessage = formatMessage(msg, group: group, severity: severity)
        printLog(formattedMessage)
    }
    
    /// Logs an error with an optional endpoint and a specific debug group.
    /// - Parameters:
    ///   - error: The error to be logged.
    ///   - endpoint: An optional endpoint associated with the error.
    ///   - group: The debug group this log belongs to.
    public func log(error: Error, endpoint: String?, group: DebugGroup) {
        guard enabledGroups().contains(group) else { return }
        var errorMessage = "\nERROR\n→ \(endpoint ?? "Unknown")\n"
        errorMessage += error.localizedDescription + "\nEND ERROR\n"
        let formattedMessage = formatMessage(errorMessage, group: group, severity: .error)
        printLog(formattedMessage)
    }
    
    /// Logs an HTTP request with a specific severity level.
    /// - Parameters:
    ///   - request: The URLRequest to be logged.
    ///   - severity: The severity level of the log.
    public func log(request: URLRequest, severity: DebugSeverity) {
        let relevantGroups: [DebugGroup] = [.networking, .networkingBody, .networkingHeaders]
        let isGroupEnabled = relevantGroups.contains(where: { enabledGroups().contains($0) })
        guard isGroupEnabled else { return }
        let requestMessage = formatRequest(request)
        let formattedMessage = formatMessage(requestMessage, group: .networking, severity: severity)
        printLog(formattedMessage)
    }
    
    /// Logs an HTTP response along with any associated error and the original request.
    /// - Parameters:
    ///   - response: The URLResponse received.
    ///   - error: An optional error that might have occurred.
    ///   - request: The original URLRequest.
    public func log(response: URLResponse?, error: Error?, request: URLRequest) {
        let relevantGroups: [DebugGroup] = [.networking, .networkingBody, .networkingHeaders]
        let isGroupEnabled = relevantGroups.contains(where: { enabledGroups().contains($0) })
        guard isGroupEnabled else { return }
        let responseMessage = formatResponse(response, error: error, request: request)
        let severity = (response as? HTTPURLResponse)?.statusCode ?? 0 >= 400 ? DebugSeverity.error : DebugSeverity.info
        let formattedMessage = formatMessage(responseMessage, group: .networking, severity: severity)
        printLog(formattedMessage)
    }
    
    /// Logs the result of attempting to parse data from a specific endpoint.
    /// - Parameters:
    ///   - data: The data to be parsed.
    ///   - endpoint: The endpoint associated with the data.
    public func log(parse data: Data?, endpoint: String) {
        guard enabledGroups().contains(.parse) else { return }
        let parseMessage = formatParse(data, endpoint: endpoint)
        let severity = data != nil ? DebugSeverity.info : DebugSeverity.error
        let formattedMessage = formatMessage(parseMessage, group: .parse, severity: severity)
        printLog(formattedMessage)
    }
    
    private func formatMessage(_ text: String, group: DebugGroup, severity: DebugSeverity) -> String {
        var formattedLine = addDate(text)
        formattedLine = addGroupIcon(formattedLine, group: group)
        formattedLine = addSeverityIcon(formattedLine, severity: severity)
        return formattedLine
    }
    
    private func formatParse(_ data: Data?, endpoint: String) -> String {
        var message = "\nParse\n→ \(endpoint)\n"
        if let data = data, let json = try? JSONSerialization.jsonObject(with: data),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            message += "Data:\n\(jsonString)\n"
        } else {
            message += "Error: Unable to parse data\n"
        }
        return message
    }
    
    private func formatRequest(_ request: URLRequest) -> String {
        var requestText = "\nRequest\n"
        
        if let method = request.httpMethod, let url = request.url {
            requestText += "→ [\(method)] \(url)\n"
        }
        
        if let fields = request.allHTTPHeaderFields,
           !fields.isEmpty,
           enabledGroups().contains(.networkingHeaders),
           let headersData = try? JSONSerialization.data(withJSONObject: fields, options: .prettyPrinted) {
            requestText += "\nHeaders:\n\(String(decoding: headersData, as: UTF8.self))\n"
        }
        
        if let httpBody = request.httpBody, let json = try? JSONSerialization.jsonObject(with: httpBody, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           enabledGroups().contains(.networkingBody) {
            let body = String(decoding: jsonData, as: UTF8.self).replacingOccurrences(of: "&", with: "\n")
            requestText += "\nBody:\n\(body)\n"
        } else if let httpBodyData = request.httpBody,
                  let body = String(data: httpBodyData, encoding: .utf8),
                  enabledGroups().contains(.networkingBody) {
            requestText += "\nBody:\n\(body.replacingOccurrences(of: "&", with: "\n"))\n"
        }
        
        return requestText
    }
    
    private func formatResponse(_ response: URLResponse?, error: Error?, request: URLRequest) -> String {
        var responseText = "\nResponse\n"
        
        if let httpResponse = response as? HTTPURLResponse {
            responseText += "→ [\(httpResponse.statusCode)] \(httpResponse.url?.absoluteString ?? "Unknown")\n"
        }
        
        if let error = error {
            responseText += "‼️ \(error.localizedDescription) ‼️\n"
        }
        
        return responseText
    }
    private func printLog(_ text: String) {
#if DEBUG
        logOutput.print(text)
#endif
    }
}

// MARK: - Logger Extensions
private extension SKLogger {
    func addGroupIcon(_ line: String, group: DebugGroup) -> String {
        let icon = iconForGroup(group)
        return "\(icon) [\(group.rawValue.uppercased())] \(line)"
    }
    
    func addSeverityIcon(_ line: String, severity: DebugSeverity) -> String {
        let icon = iconForSeverity(severity)
        return "\(icon) \(line) \(icon)"
    }
    
    func addDate(_ line: String) -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy - HH:mm:ss:SSSS"
        let dateString = formatter.string(from: date)
        return "[\(dateString)] \(line)"
    }
    
    func iconForGroup(_ group: DebugGroup) -> String {
        switch group {
        case .networking:
            return "📞"
        case .keychain:
            return "📦"
        case .parse:
            return "🗒"
        case .secureEnclave:
            return "🔐"
        case .configuration:
            return "⚙️"
        case .system:
            return "📱"
        case .filesystem:
            return "💿"
        case .token:
            return "📝"
        case .alert:
            return "🚨"
        case .networkingHeaders:
            return "📃"
        case .networkingBody:
            return "🔋"
        case .debug:
            return "🪲"
        case .database:
            return "🥫"
        }
    }
    
    func iconForSeverity(_ severity: DebugSeverity) -> String {
        switch severity {
        case .error:
            return "‼️"
        case .info:
            return "ℹ️"
        }
    }
}
