//
//  Coordinator.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 21/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import UIKit

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
