//
//  SKKeychain.swift
//  
//
//  Created by Oscar Cardona on 17/1/21.
//  Copyright © 2021 Cardona.tv. All rights reserved.

import Foundation
import Security


public protocol SKKeychain {
    func save(_ string: String?, forKey key: String) throws
    func save(_ data: Data?, forKey key: String) throws
    func loadData(withKey key: String) throws -> Data
    func loadString(withKey key: String) throws -> String?
    func delete(items: [String])
}


public final class DefaultSKKeychain: SKKeychain {
    public init() {}
    
    public func save(_ data: Data?, forKey key: String) throws {
        let query = keychainQuery(withKey: key)
        
        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = data {
                SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                SKLogger.shared.log(msg: "Keychain Update Value for key: \(key)", group: .keychain, severity: .info)
            } else {
                SecItemDelete(query)
                SKLogger.shared.log(msg: "Keychain Delete Value for key: \(key)", group: .keychain, severity: .info)
            }
        } else {
            if let dictData = data {
                query.setValue(dictData, forKey: kSecValueData as String)
                SecItemAdd(query, nil)
                SKLogger.shared.log(msg: "Keychain Update Value for key: \(key)", group: .keychain, severity: .info)
            } else {
                SKLogger.shared.log(msg: "Keychain Store data error with key: \(key)", group: .keychain, severity: .error)
                throw SKError.storingData(msg: "Keychain")
            }
        }
    }
    
   public func save(_ string: String?, forKey key: String) throws {
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)
        try save(objectData, forKey: key)
    }
    
    public func loadData(withKey key: String) throws -> Data {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            SKLogger.shared.log(msg: "Keychain Load error with key: \(key)", group: .keychain, severity: .error)
            throw SKError.storedData(msg: "Keychain error for key: \(key)")
        }
        SKLogger.shared.log(msg: "Decrypt key: \(key)", group: .keychain, severity: .info)
        return resultsData
    }
    
    public func loadString(withKey key: String) throws -> String? {
        let data = try loadData(withKey: key)
        return String(data: data, encoding: .utf8)
    }
    
    public func delete(items: [String]) {
        items.forEach { key in
            let query = keychainQuery(withKey: key)
            SecItemDelete(query)
        }
    }
    
    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String)
        
        return result
    }
}
