//
//  RepositoryTask.swift
//  
//
//  Created by Oscar Cardona on 20/3/22.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//


import Foundation

public struct RepositoryTask: Cancellable {
    public let networkTask: NetworkCancellable?

    public init(networkTask: NetworkCancellable?) {
        self.networkTask = networkTask
    }

    public func cancel() {
        networkTask?.cancel()
    }
}
