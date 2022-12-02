//
//  SKMD5.swift
//  
//
//  Created by oscar on 3/9/22.
//

import Foundation
import CryptoKit

public func MD5(string: String) -> String {
    let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())

    return digest.map {
        String(format: "%02hhx", $0)
    }.joined()
}
