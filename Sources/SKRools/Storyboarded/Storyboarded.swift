//
//  Storyboarded.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 21/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation
import UIKit

public protocol Storyboarded {
    static func instantiate(storyboardName: String) throws -> Self
}

extension Storyboarded where Self: UIViewController {
    static public func instantiate(storyboardName: String = "Main") -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)

        // instantiate a view controller with that identifier, and force cast as the type was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
