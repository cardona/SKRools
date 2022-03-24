//
//  NetworkServiceTests.swift
//  
//
//  Created by Oscar Cardona on 24/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import XCTest
@testable import SKRools

class NetworkServiceTests: XCTestCase {
    
    private struct EndpointMock: Requestable {
        var path: String
        var isFullPath: Bool = false
        var method: HTTPMethodType
        var headerParamaters: [String: String] = [:]
        var queryParametersEncodable: Encodable?
        var queryParameters: [String: Any] = [:]
        var bodyParamatersEncodable: Encodable?
        var bodyParamaters: [String: Any] = [:]
        var bodyEncoding: BodyEncoding = .stringEncodingAscii
        
        init(path: String, method: HTTPMethodType) {
            self.path = path
            self.method = method
        }
    }
    
    private enum NetworkErrorMock: Error {
        case someError
    }

    func test_whenMockDataPassed_shouldReturnProperResponse() {
        
        // GIVEN
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return correct data")
        
        let expectedResponseData = "Response data".data(using: .utf8)!
        let session = NetworkSessionManagerMock(response: nil, data: expectedResponseData, error: nil)
        let sut = DefaultNetworkService(config: config, sessionManager: session)
        
        // WHEN
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.com", method: .get)) { result in
            guard let responseData = try? result.get() else {
                XCTFail("Should return proper response")
                return
            }
            XCTAssertEqual(responseData.data, expectedResponseData)
            expectation.fulfill()
        }
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_whenMalformedUrlPassed_shouldReturnUrlGenerationError() {
        
        // GIVEN
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return correct data")
        
        let expectedResponseData = "Response data".data(using: .utf8)!
        let session = NetworkSessionManagerMock(response: nil, data: expectedResponseData, error: nil)
        let sut = DefaultNetworkService(config: config, sessionManager: session)
        
        // WHEN
        _ = sut.request(endpoint: EndpointMock(path: "¡`´ño9ą", method: .get)) { result in
            do {
                _ = try result.get()
                XCTFail("Should throw url generation error")
            } catch let error {
                guard case NetworkError.urlGeneration = error else {
                    XCTFail("Should throw url generation error")
                    return
                }
                
                expectation.fulfill()
            }
        }
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
    }

    func test_whenStatusCodeEqualOrAbove400_shouldReturnhasStatusCodeError() {
        
        // GIVEN
        let config = NetworkConfigurableMock()
        let expectation = self.expectation(description: "Should return hasStatusCode error")
        
        let response = HTTPURLResponse(url: URL(string: "test_url")!,
                                       statusCode: 500,
                                       httpVersion: "1.1",
                                       headerFields: [:])
        let session = NetworkSessionManagerMock(response: response, data: nil, error: NetworkErrorMock.someError)
        let sut = DefaultNetworkService(config: config, sessionManager: session)
        
        // WHEN
        _ = sut.request(endpoint: EndpointMock(path: "http://mock.com", method: .get)) { result in
            do {
                _ = try result.get()
                XCTFail("Should not happen")
            } catch let error {
                if case NetworkError.error(let statusCode, _, _) = error {
                    XCTAssertEqual(statusCode, 500)
                    expectation.fulfill()
                }
            }
        }
        
        // THEN
        wait(for: [expectation], timeout: 0.1)
    }
}
