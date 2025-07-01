//
//  AppRoute.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

/// A type that represents a navigable route in the app.
///
/// Each route must provide:
/// - `path`: The resolved navigable path (e.g., "/product/42").
/// - `pattern`: The route pattern used for matching (e.g., "/product/:id").
///
/// This allows consistent navigation and route resolution across modules.
public protocol AppRoute: Hashable, Sendable {
    
    /// The full navigable path string (e.g., "/product/42").
    var path: String { get }
    
    /// The route pattern used during parsing and registration (e.g., "/product/:id").
    var pattern: String { get }
}

public extension AppRoute {
    var asWrapped: Route {
        .wrapped(WrappedAppRoute(self))
    }
}
