//
//  Boxing.swift
//  Pattern MVVM
//
//  Created by Oscar Cardona on 16/02/2020.
//  Copyright © 2020 Cardona.tv. All rights reserved.
//

/// `Box` is a generic class that enables the binding of a value and allows listeners to react to changes in this value.
/// It's typically used in MVVM architectural patterns to synchronize views with view models.
///
/// - Parameters:
///   - T: The type of value to be observed.
///
/// Usage:
/// 1. Initialize `Box` with an initial value.
/// 2. Bind a listener to react to changes in the value.
/// 3. Update the `value` as needed. The listener will be notified of these changes.
///
/// Example:
/// ```
/// var myValue: Box<Int> = Box(0)
/// myValue.bind { newValue in
///     print("Value changed to \(newValue)")
/// }
/// myValue.value = 10 // Prints: Value changed to 10
/// ```
public class Box<T> {
    public typealias Listener = (T) -> Void
    private var listener: Listener?

    public var value: T {
        didSet {
            listener?(value)
        }
    }

    public init(_ value: T) {
        self.value = value
    }
    
    /// Binds a listener to the `Box` that will be called whenever the `value` changes.
    /// - Parameter listener: A closure that takes the new value as a parameter.
    public func bind(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
}
