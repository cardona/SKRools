//
//  SKCrypto.swift
//  
//
//  Created by Oscar Cardona on 17/1/21.
//  Copyright © 2021 Cardona.tv. All rights reserved.

import Foundation
import CryptoKit
import Security
import LocalAuthentication

public protocol SKCrypto {
    func createPrivateKey() throws
    func symmetricKey() throws -> SymmetricKey
    func encrypt(text: String, key: SymmetricKey) throws -> Data?
    func decrypt(data: Data, key: SymmetricKey) throws -> Any?
}

/// `DefaultSKCrypto` is a class that implements the `SKCrypto` protocol to provide encryption and decryption functionalities using the Secure Enclave on compatible Apple devices. It utilizes the Secure Enclave to generate and store a private key securely and uses this key to create a symmetric key for encryption and decryption.
///
/// Usage:
/// 1. Create an instance of `DefaultSKCrypto`.
/// 2. Use `createPrivateKey()` to generate a new private key in the Secure Enclave.
/// 3. Use `symmetricKey()` to retrieve the symmetric key derived from the private key.
/// 4. Encrypt or decrypt data using `encrypt(text:key:)` and `decrypt(data:key:)`.
///
/// Note:
/// - The class checks whether the Secure Enclave is available and falls back to a hardcoded key if not.
/// - The class also checks if it's running on a simulator, where the Secure Enclave is not available.
public final class DefaultSKCrypto: SKCrypto {
    public init() {}
    private static let keychainKeyPrivateKey = "skKeychainKeyPrivateKey"
    private let keychain: SKKeychain = DefaultSKKeychain()
    
    /// Generates a new private key and stores it in the Secure Enclave, if available.
    /// - Throws: `SKError.privateKey` if there is an error in creating the private key.
    public func createPrivateKey() throws {
 
        if SecureEnclave.isAvailable && !isSimulator() {

            SKLogger.shared.log(msg: "Secure Enclave is available ", group: .secureEnclave, severity: .info)
            
            guard
                let data = try? SecureEnclave.P256.KeyAgreement.PrivateKey().dataRepresentation
            else {
                let msg = "Create PrivateKey from Secure Encalve"
                SKLogger.shared.log(msg: msg, group: .secureEnclave, severity: .info)
                throw SKError.privateKey(msg: msg)
            }
            
            guard
                let privateKey = try? CryptoKit.SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation: data, authenticationContext: LAContext())
            else {
                let msg = "Create PrivateKey from Secure Encalve"
                SKLogger.shared.log(msg: msg, group: .secureEnclave, severity: .info)
                throw SKError.privateKey(msg: msg)
            }
            SKLogger.shared.log(msg: "Created Private Key: \(privateKey) ", group: .secureEnclave, severity: .info)
            try keychain.save(privateKey.dataRepresentation, forKey: DefaultSKCrypto.keychainKeyPrivateKey)
        } else {
            SKLogger.shared.log(msg: "Secure Enclave is not available", group: .secureEnclave, severity: .info)
        }
    }
    
    /// Retrieves the symmetric key derived from the private key stored in the Secure Enclave.
    /// - Returns: A `SymmetricKey` derived from the private key.
    /// - Throws: `SKError.symmetricKey` if there is an error in retrieving or deriving the symmetric key.
    public func symmetricKey() throws -> SymmetricKey {
        if SecureEnclave.isAvailable && !isSimulator() {
            let dataRepresentation = try keychain.loadData(withKey: DefaultSKCrypto.keychainKeyPrivateKey)
        guard
            let privateKey = try? CryptoKit.SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation: dataRepresentation)
        else {
            let msg = "Retrieve SymmetricKey from Secure Encalve"
            SKLogger.shared.log(msg: msg, group: .secureEnclave, severity: .info)
            throw SKError.symmetricKey(msg: msg)
        }
        let hash = SHA256.hash(data: privateKey.publicKey.rawRepresentation)
            SKLogger.shared.log(msg: "Retrieve SymmetricKey from Secure enclave", group: .secureEnclave, severity: .info)
        
            return SymmetricKey(data: hash)
            
        } else {
            let data = Data("l1l78t:6ft-yvuib$gho?=IJ;L;POKJdlw".utf8)
            let hash = SHA256.hash(data: data)
            SKLogger.shared.log(msg: "Retrieve SymmetricKey from hardcoded key", group: .secureEnclave, severity: .info)
            return SymmetricKey(data: hash)
        }
    }
    
    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}

// MARK: Encryption / Decryption

extension DefaultSKCrypto {
    /// Encrypts the given text using the provided symmetric key.
    /// - Parameters:
    ///   - text: The text to be encrypted.
    ///   - key: The symmetric key to use for encryption.
    /// - Returns: An optional `Data` object representing the encrypted text.
    /// - Throws: `SKError.encryptingData` if there is an error during encryption.
   public func encrypt(text: String, key: SymmetricKey) throws -> Data? {
        guard
            let data = text.data(using: .utf8),
            let sealedBox  = try? AES.GCM.seal(data, using: key, nonce: AES.GCM.Nonce())
        else {
            SKLogger.shared.log(msg: "text: \(text)", group: .secureEnclave, severity: .error)
            throw SKError.encryptingData(msg: "\(text)")
        }
        SKLogger.shared.log(msg: "Encrypt text: \(text)", group: .secureEnclave, severity: .info)
        
        let dataString = sealedBox.combined?.withUnsafeBytes {
            return Data(Array($0)).base64EncodedString()
        }
        SKLogger.shared.log(msg: "Encrypted data: \(dataString ?? "")", group: .secureEnclave, severity: .info)
        
        return sealedBox.combined
   }
    
    /// Decrypts the given data using the provided symmetric key.
    /// - Parameters:
    ///   - data: The data to be decrypted.
    ///   - key: The symmetric key to use for decryption.
    /// - Returns: An optional decrypted string.
    /// - Throws: `SKError.decryptingData` if there is an error during decryption.
    public func decrypt(data: Data, key: SymmetricKey) throws -> Any? {
        let dataString = data.withUnsafeBytes {
            return Data(Array($0)).base64EncodedString()
        }
        
        SKLogger.shared.log(msg: "Decrypt data: \(dataString)", group: .secureEnclave, severity: .info)
        
        guard
            let sealedBoxToOpen = try? AES.GCM.SealedBox(combined: data),
            let decryptedData = try? AES.GCM.open(sealedBoxToOpen, using: key)
        else {
            throw SKError.decryptingData(msg: "\(dataString)")
        }
        
        SKLogger.shared.log(msg: "Decrypted text: \(String(data: decryptedData, encoding: .utf8) ?? "")", group: .secureEnclave, severity: .info)
        
        return String(data: decryptedData, encoding: .utf8)
    }
}
