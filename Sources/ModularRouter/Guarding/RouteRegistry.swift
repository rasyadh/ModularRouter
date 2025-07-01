//
//  RouteRegistry.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Foundation

/// A registered route entry consisting of a route pattern and an optional guard.
///
/// `RouteRegistry` stores `RegisteredRoute` instances to allow metadata like route guards
/// to be associated with individual route patterns.
public struct RegisteredRoute {
    
    /// The route pattern used for matching (e.g., "/product/:id").
    public let pattern: RoutePattern
    
    /// An optional route guard used to allow/block navigation.
    public let routeGuard: RouteGuard?
}

/// A singleton registry for managing all route patterns and their associated metadata.
///
/// This class acts as the central source of truth for:
/// - Registering route patterns from feature modules
/// - Preventing duplicate registrations
/// - Looking up guards for a given route
public final class RouteRegistry {
    
    /// Shared singleton instance of the registry.
    public static let shared = RouteRegistry()
    
    /// Internal storage of route pattern keys to registered routes.
    private var routes: [String: RegisteredRoute] = [:]
    
    /// Private initializer to enforce singleton usage.
    private init() {}
    
    /// Registers a new route pattern and optional route guard.
    ///
    /// - Parameters:
    ///   - pattern: The `RoutePattern` describing the route.
    ///   - routeGuard: An optional guard to apply to this route.
    ///
    /// - Throws: `RouteRegistryError.duplicatePattern` if the pattern is already registered.
    public func register(_ pattern: RoutePattern, guard routeGuard: RouteGuard? = nil) throws {
        if routes[pattern.pattern] != nil {
            throw RouteRegistryError.duplicatePattern(pattern.pattern)
        }
        
        routes[pattern.pattern] = RegisteredRoute(
            pattern: pattern,
            routeGuard: routeGuard
        )
    }
    
    /// Returns all registered route patterns.
    ///
    /// This is typically used by `RouteParser` to attempt path matching.
    ///
    /// - Returns: An array of all registered `RoutePattern` instances.
    public func allPatterns() -> [RoutePattern] {
        routes.values.map(\.pattern)
    }
    
    /// Returns the guard associated with the given wrapped route, if any.
    ///
    /// Guards are matched using the route's registered `pattern`, not its resolved `path`.
    /// This lookup allows the system to evaluate access control before navigating.
    ///
    /// - Parameter wrapped: A `WrappedAppRoute` whose `.pattern` will be used for lookup.
    /// - Returns: The associated `RouteGuard` or `nil` if the route is unguarded.
    public func routeGuard(for wrapped: WrappedAppRoute) -> RouteGuard? {
        routes[wrapped.pattern]?.routeGuard
    }
    
    /// Convenience overload for extracting a guard from a `Route` enum.
    ///
    /// This enables guard checks to be done directly on `Route` values,
    /// such as during deep link resolution or stack-based navigation.
    ///
    /// - Parameter route: The parsed or constructed `Route` enum.
    /// - Returns: The associated `RouteGuard`, or `nil`.
    public func routeGuard(for route: Route) -> RouteGuard? {
        if case .wrapped(let wrapped) = route {
            return routeGuard(for: wrapped)
        }
        return nil
    }
}

#if DEBUG
extension RouteRegistry {
    public func reset() {
        routes.removeAll()
    }
}
#endif
