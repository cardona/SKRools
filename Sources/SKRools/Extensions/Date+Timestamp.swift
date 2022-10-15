//
//  File.swift
//  
//
//  Created by Oscar Cardona on 17/4/22.
//

import Foundation


extension Date {
    public var timestamp: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
