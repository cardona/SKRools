//
//  SKRoolsConfigTests.swift
//  
//
//  Created by Oscar on 28/1/24.
//  Copyright © 2024 Cardona.tv. All rights reserved.
//

import XCTest
@testable import SKRools

final class SKRoolsConfigTests: XCTestCase {

    override func tearDown() {
        super.tearDown()
        SKRoolsConfig.shared.networkBaseURL = ""
        SKRoolsConfig.shared.networkPublicApiKey = ""
        SKRoolsConfig.shared.networkPrivateApiKey = ""
        SKRoolsConfig.shared.networkCertificate = ""
        SKRoolsConfig.shared.loggerDebugGroups = [.networking]
    }
    
    func testNetworkConfiguration() {
        // Given
        let baseURL = "https://api.example.com"
        let publicApiKey = "1234567890"
        let privateApiKey = "abcdefghij"
        let certificate = "-----BEGIN CERTIFICATE----- ..."

        // When
        SKRoolsConfig.shared.networkBaseURL = baseURL
        SKRoolsConfig.shared.networkPublicApiKey = publicApiKey
        SKRoolsConfig.shared.networkPrivateApiKey = privateApiKey
        SKRoolsConfig.shared.networkCertificate = certificate

        // Then
        XCTAssertEqual(SKRoolsConfig.shared.networkBaseURL, baseURL)
        XCTAssertEqual(SKRoolsConfig.shared.networkPublicApiKey, publicApiKey)
        XCTAssertEqual(SKRoolsConfig.shared.networkPrivateApiKey, privateApiKey)
        XCTAssertEqual(SKRoolsConfig.shared.networkCertificate, certificate)
    }

    func testLoggerConfiguration() {
        // Given
        let debugGroups: [DebugGroup] = [.networking, .secureEnclave, .system]

        // When
        SKRoolsConfig.shared.loggerDebugGroups = debugGroups

        // Then
        XCTAssertEqual(SKRoolsConfig.shared.loggerDebugGroups, debugGroups)
    }
}
