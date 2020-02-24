//
//  ServiceLocator.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 14/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation

public protocol Resolver {
    func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType
}

public protocol ServiceFactory {
    associatedtype ServiceType
    func resolve(_ resolver: Resolver) -> ServiceType
}

public struct BasicServiceFactory<ServiceType>: ServiceFactory {
    private let factory: (Resolver) -> ServiceType

    public init(_ type: ServiceType.Type, factory: @escaping (Resolver) -> ServiceType) {
        self.factory = factory
    }

    public func resolve(_ resolver: Resolver) -> ServiceType {
        return factory(resolver)
    }
}

public final class AnyServiceFactory {
    private let _resolve: (Resolver) -> Any
    private let _supports: (Any.Type) -> Bool

    public init<T: ServiceFactory>(_ serviceFactory: T) {
        self._resolve = { resolver -> Any in
            serviceFactory.resolve(resolver)
        }
        self._supports = { $0 == T.ServiceType.self }
    }

    public func resolve<ServiceType>(_ resolver: Resolver) -> ServiceType {
        return _resolve(resolver) as! ServiceType
    }

    public func supports<ServiceType>(_ type: ServiceType.Type) -> Bool {
        return _supports(type)
    }
}
