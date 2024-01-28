//
//  SKLoggerTests.swift
//
//
//  Created by Oscar on 28/1/24.
//  Copyright © 2024 Cardona.tv. All rights reserved.
//

import XCTest
@testable import SKRools

final class SKLoggerTests: XCTestCase {
    
    func testLogMessage() {
        // Given
        let testLogOutput = TestLogOutput()
        SKLogger.shared.logOutput = testLogOutput
        let message = "Hello, world!"
        let group = DebugGroup.debug
        SKRoolsConfig.shared.loggerDebugGroups = [group]
        
        // When
        SKLogger.shared.log(msg: message, group: group, severity: .info)
        
        // Then
        XCTAssertFalse(testLogOutput.messages.isEmpty)
        
        let loggedMessage = testLogOutput.messages[0]
        
        // Check for the presence of the message
        XCTAssertTrue(loggedMessage.contains("Hello, world!"))
        
        // Check for the correct icon
        XCTAssertTrue(loggedMessage.contains("🪲"))
        
        // Check for the correct group
        XCTAssertTrue(loggedMessage.contains("[DEBUG]"))
        
        // Check for the correct severity icon
        XCTAssertTrue(loggedMessage.contains("ℹ️"))
        
        // Check for the correct date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy - HH:mm:ss:SSSS"
        let dateRegex = "\\[\\d{2}\\.\\d{2}\\.\\d{4} - \\d{2}:\\d{2}:\\d{2}:\\d{4}\\]"
        let dateRange = loggedMessage.range(of: dateRegex, options: .regularExpression)
        XCTAssertNotNil(dateRange)
    }
    
    func testLogError() {
        // Given
        let testLogOutput = TestLogOutput()
        SKLogger.shared.logOutput = testLogOutput
        let error = NSError(domain: "com.example.error", code: 100, userInfo: nil)
        let group = DebugGroup.networking
        SKRoolsConfig.shared.loggerDebugGroups = [group]
        
        // When
        SKLogger.shared.log(error: error, endpoint: "users", group: group)
        
        // Then
        XCTAssertFalse(testLogOutput.messages.isEmpty)
        let loggedMessage = testLogOutput.messages[0]
        
        XCTAssertTrue(loggedMessage.contains("(com.example.error error 100.)"))
        XCTAssertTrue(loggedMessage.contains("📞"))
        XCTAssertTrue(loggedMessage.contains("[NETWORKING]"))
        XCTAssertTrue(loggedMessage.contains("‼️"))
        verifyDateFormat(in: loggedMessage)
    }
    
    func testLogRequest() {
        // Given
        let testLogOutput = TestLogOutput()
        SKLogger.shared.logOutput = testLogOutput
        let url = URL(string: "https://api.example.com/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data("{\"name\": \"John Doe\"}".utf8)
        SKRoolsConfig.shared.loggerDebugGroups = [.networking, .networkingBody, .networkingHeaders]
        
        // When
        SKLogger.shared.log(request: request, severity: .info)
        
        // Then
        XCTAssertFalse(testLogOutput.messages.isEmpty)
        let loggedMessage = testLogOutput.messages[0]
        
        XCTAssertTrue(loggedMessage.contains("[POST] https://api.example.com/users"))
        XCTAssertTrue(loggedMessage.contains("John Doe"))
        XCTAssertTrue(loggedMessage.contains("📞"))
        XCTAssertTrue(loggedMessage.contains("[NETWORKING]"))
        XCTAssertTrue(loggedMessage.contains("ℹ️"))
        verifyDateFormat(in: loggedMessage)
    }
    
    func testLogResponse() {
        // Given
        let testLogOutput = TestLogOutput()
        SKLogger.shared.logOutput = testLogOutput
        let url = URL(string: "https://api.example.com/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let group = DebugGroup.networking
        SKRoolsConfig.shared.loggerDebugGroups = [group]
        
        // When
        SKLogger.shared.log(response: response, error: nil, request: request)
        
        // Then
        XCTAssertFalse(testLogOutput.messages.isEmpty)
        let loggedMessage = testLogOutput.messages[0]
        
        XCTAssertTrue(loggedMessage.contains("[200] https://api.example.com/users"))
        XCTAssertTrue(loggedMessage.contains("📞"))
        XCTAssertTrue(loggedMessage.contains("[NETWORKING]"))
        XCTAssertTrue(loggedMessage.contains("ℹ️"))
        verifyDateFormat(in: loggedMessage)
    }
    
    func testLogParseData() {
        // Given
        let testLogOutput = TestLogOutput()
        SKLogger.shared.logOutput = testLogOutput
        let data = "{\"name\": \"John Doe\"}".data(using: .utf8)!
        let endpoint = "users"
        SKRoolsConfig.shared.loggerDebugGroups = [.parse]
        
        // When
        SKLogger.shared.log(parse: data, endpoint: endpoint)
        
        // Then
        XCTAssertFalse(testLogOutput.messages.isEmpty)
        let loggedMessage = testLogOutput.messages[0]
        
        XCTAssertTrue(loggedMessage.contains("John Doe"))
        XCTAssertTrue(loggedMessage.contains("🗒"))
        XCTAssertTrue(loggedMessage.contains("[PARSE]"))
        XCTAssertTrue(loggedMessage.contains("ℹ️"))
        verifyDateFormat(in: loggedMessage)
    }
    
    // Helper method to verify date format
    private func verifyDateFormat(in message: String) {
        let dateRegex = "\\[\\d{2}\\.\\d{2}\\.\\d{4} - \\d{2}:\\d{2}:\\d{2}:\\d{4}\\]"
        let dateRange = message.range(of: dateRegex, options: .regularExpression)
        XCTAssertNotNil(dateRange)
    }
}

class TestLogOutput: SKLoggerLogOutput {
    var messages: [String] = []
    
    func print(_ message: String) {
        messages.append(message)
    }
}
