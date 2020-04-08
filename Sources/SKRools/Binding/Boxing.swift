//
//  Boxing.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 16/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

public final class Box<T> {
    public typealias Listener = (T) -> Void
    private var listener: Listener?
    
    public var value: T {
        didSet { execute(with: value) }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func bind(listener: Listener?) {
        self.listener = listener
        execute(with: value)
    }
    
    private func execute(with value: T) {
        Thread.isMainThread ? listener?(value) : DispatchQueue.main.async { self.listener?(value) }
    }
}
