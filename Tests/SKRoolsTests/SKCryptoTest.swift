//
//  SKCryptoTest.swift
//
//
//  Created by Oscar on 28/1/24.
//  Copyright © 2024 Cardona.tv. All rights reserved.
//

import XCTest
@testable import SKRools

class SKCryptoTests: XCTestCase {
    var crypto: DefaultSKCrypto?

    override func setUp() {
        super.setUp()
        crypto = DefaultSKCrypto()
    }

    override func tearDown() {
        crypto = nil
        super.tearDown()
    }

    func testCreatePrivateKey() {
        XCTAssertNoThrow(try crypto?.createPrivateKey())
    }
    
    func testSymmetricKey() {
        XCTAssertNoThrow(try {
            let key = try crypto?.symmetricKey()
            XCTAssertNotNil(key)
        }())
    }
    
    func testEncryptDecrypt() {
        let text = "Hello, World!"
        do {
            guard let key = try crypto?.symmetricKey() else { return }
            let encryptedData = try crypto?.encrypt(text: text, key: key)
            XCTAssertNotNil(encryptedData)

            let decryptedText = try crypto?.decrypt(data: encryptedData!, key: key) as? String
            XCTAssertEqual(decryptedText, text)
        } catch {
            XCTFail("Encryption/Decryption failed with error: \(error)")
        }
    }
}
