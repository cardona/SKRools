//
//  Container.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 14/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

import Foundation

public struct Container: Resolver {
    private let factories: [AnyServiceFactory]

    public init() {
        self.factories = []
    }

    public init(factories: [AnyServiceFactory]) {
        self.factories = factories
    }

    public func register<T>(_ type: T.Type, instance: T) -> Container {
        return register(type) { _ in instance }
    }

    @discardableResult
    public func register<ServiceType>(_ type: ServiceType.Type, _ factory: @escaping (Resolver) -> ServiceType) -> Container {
        assert(!factories.contains(where: { $0.supports(type) }))
        let newFactory = BasicServiceFactory<ServiceType>(type, factory: { resolver in
            factory(resolver)
        })

        return .init(factories: factories + [AnyServiceFactory(newFactory)])
    }

    public func resolve<ServiceType>(_ type: ServiceType.Type) -> ServiceType {
        guard let factory = factories.first(where: { $0.supports(type) }) else {
            fatalError("No factory found")
        }
        return factory.resolve(self)
    }
}
