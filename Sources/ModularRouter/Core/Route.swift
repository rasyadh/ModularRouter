//
//  Route.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Foundation

/// A type-erased wrapper for any `AppRoute`, enabling it to be stored in enums
/// and collections while preserving `Hashable`, `Sendable`, and equatability.
///
/// This is necessary because Swift does not allow existential protocols with
/// `Self` or associated type requirements to be used directly in `Hashable` contexts.
public struct WrappedAppRoute: Hashable, Sendable {
    private let _hash: @Sendable (inout Hasher) -> Void
    private let _equals: @Sendable (any AppRoute) -> Bool
    private let _path: @Sendable () -> String
    private let _pattern: @Sendable () -> String
    private let _route: any AppRoute
    
    /// The path representation of the wrapped route (e.g., "/products/42").
    public var path: String { _path() }
    
    /// The pattern associated with the route (e.g., "/products/:id").
    public var pattern: String { _pattern() }
    
    /// The underlying concrete route (type-erased).
    public var base: any AppRoute { _route }
    
    /// Creates a type-erased wrapper around any `AppRoute`.
    ///
    /// - Parameter route: A concrete type conforming to `AppRoute`.
    public init<T: AppRoute>(_ route: T) {
        _route = route
        _hash = { hasher in route.hash(into: &hasher) }
        _path = { route.path }
        _pattern = { route.pattern }
        _equals = { other in
            guard let otherTyped = other as? T else { return false }
            return otherTyped == route
        }
    }
    
    public static func == (lhs: WrappedAppRoute, rhs: WrappedAppRoute) -> Bool {
        lhs._equals(rhs._route)
    }
    
    public func hash(into hasher: inout Hasher) {
        _hash(&hasher)
    }
}

/// A high-level route type used throughout the app for navigation.
///
/// - `wrapped`: A valid, registered route provided by a feature module.
/// - `notFound`: A fallback route when the requested path doesn't match any known pattern.
public enum Route: Hashable, Sendable {
    case wrapped(WrappedAppRoute)
    case notFound(String)
    
    /// Returns a string path for debugging/logging.
    public var pathDescription: String {
        switch self {
        case .wrapped(let wrapped): return wrapped.path
        case .notFound(let path): return "[NOT FOUND] \(path)"
        }
    }
}
