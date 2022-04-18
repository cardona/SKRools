//
//  SpinnerView.swift
//  
//
//  Created by Oscar Cardona on 20/03/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation
import UIKit

public class SpinnerViewController: UIViewController {
    var spinner = UIActivityIndicatorView(style: .large)

    override public func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

