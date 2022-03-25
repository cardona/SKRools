//
//  SKRoolsConfig.swift
//  
//
//  Created by Oscar Cardona on 21/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public final class SKRoolsConfig {
    
    public static let shared = SKRoolsConfig()
    private var currentBaseURL = "noURLBase!"

    public func config(url: String) {
        currentBaseURL = url
    }
    
    func baseURL() -> String {
        return currentBaseURL
    }
}
