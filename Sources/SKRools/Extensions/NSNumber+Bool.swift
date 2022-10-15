//
//  File.swift
//  
//
//  Created by Oscar Cardona on 17/4/22.
//

import Foundation

extension NSNumber {
    public func isBool() -> Bool {
        let boolID = CFBooleanGetTypeID()
        let numID = CFGetTypeID(self)
        
        return numID == boolID
    }
}
