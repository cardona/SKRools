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

public final class DefaultSKCrypto: SKCrypto {
    public init() {}
    private static let keychainKeyPrivateKey = "skKeychainKeyPrivateKey"
    private let keychain: SKKeychain = DefaultSKKeychain()
    
    public func createPrivateKey() throws {
 
        if SecureEnclave.isAvailable && !isSimulator() {

            Logger.shared.log(msg: "Secure Enclave is available ", group: .secureEnclave, severity: .info)
            
            guard
                let data = try? SecureEnclave.P256.KeyAgreement.PrivateKey().dataRepresentation
            else {
                let msg = "Create PrivateKey from Secure Encalve"
                Logger.shared.log(msg: msg, group: .secureEnclave, severity: .info)
                throw SKError.privateKey(msg: msg)
            }
            
            guard
                let privateKey = try? CryptoKit.SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation: data, authenticationContext: LAContext())
            else {
                let msg = "Create PrivateKey from Secure Encalve"
                Logger.shared.log(msg: msg, group: .secureEnclave, severity: .info)
                throw SKError.privateKey(msg: msg)
            }
            Logger.shared.log(msg: "Created Private Key: \(privateKey) ", group: .secureEnclave, severity: .info)
            try keychain.save(privateKey.dataRepresentation, forKey: DefaultSKCrypto.keychainKeyPrivateKey)
        } else {
            Logger.shared.log(msg: "Secure Enclave is not available", group: .secureEnclave, severity: .info)
        }
    }
    
    public func symmetricKey() throws -> SymmetricKey {
        if SecureEnclave.isAvailable && !isSimulator() {
            let dataRepresentation = try keychain.loadData(withKey: DefaultSKCrypto.keychainKeyPrivateKey)
        guard
            let privateKey = try? CryptoKit.SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation: dataRepresentation)
        else {
            let msg = "Retrieve SymmetricKey from Secure Encalve"
            Logger.shared.log(msg: msg, group: .secureEnclave, severity: .info)
            throw SKError.symmetricKey(msg: msg)
        }
        let hash = SHA256.hash(data: privateKey.publicKey.rawRepresentation)
            Logger.shared.log(msg: "Retrieve SymmetricKey from Secure enclave", group: .secureEnclave, severity: .info)
        
            return SymmetricKey(data: hash)
            
        } else {
            let data = Data("l1l78t:6ft-yvuib$gho?=IJ;L;POKJdlw".utf8)
            let hash = SHA256.hash(data: data)
            Logger.shared.log(msg: "Retrieve SymmetricKey from hardcoded key", group: .secureEnclave, severity: .info)
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
   public func encrypt(text: String, key: SymmetricKey) throws -> Data? {
        guard
            let data = text.data(using: .utf8),
            let sealedBox  = try? AES.GCM.seal(data, using: key, nonce: AES.GCM.Nonce())
        else {
            Logger.shared.log(msg: "text: \(text)", group: .secureEnclave, severity: .error)
            throw SKError.encryptingData(msg: "\(text)")
        }
        Logger.shared.log(msg: "Encrypt text: \(text)", group: .secureEnclave, severity: .info)
        
        let dataString = sealedBox.combined?.withUnsafeBytes {
            return Data(Array($0)).base64EncodedString()
        }
        Logger.shared.log(msg: "Encrypted data: \(dataString ?? "")", group: .secureEnclave, severity: .info)
        
        return sealedBox.combined
    }
    
    public func decrypt(data: Data, key: SymmetricKey) throws -> Any? {
        let dataString = data.withUnsafeBytes {
            return Data(Array($0)).base64EncodedString()
        }
        
        Logger.shared.log(msg: "Decrypt data: \(dataString)", group: .secureEnclave, severity: .info)
        
        guard
            let sealedBoxToOpen = try? AES.GCM.SealedBox(combined: data),
            let decryptedData = try? AES.GCM.open(sealedBoxToOpen, using: key)
        else {
            throw SKError.decryptingData(msg: "\(dataString)")
        }
        
        Logger.shared.log(msg: "Decrypted text: \(String(data: decryptedData, encoding: .utf8) ?? "")", group: .secureEnclave, severity: .info)
        
        return String(data: decryptedData, encoding: .utf8)
    }
}
