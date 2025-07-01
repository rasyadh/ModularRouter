//
//  RoutePattern.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Foundation

/// Represents a route definition with a pattern string and a match function.
///
/// `RoutePattern` is used to map incoming paths (with parameters) to specific `Route` values.
/// Typically registered by feature modules and consumed by the main router.
public struct RoutePattern {
    /// The route pattern string (e.g. "/", "/detail/:id").
    /// This is mainly for registration and debugging.
    public let pattern: String
    
    /// The function that attempts to match parameters against this pattern.
    /// Returns a `Route` if the pattern is satisfied, or `nil` otherwise.
    public let match: (RouteParameters) -> Route?
    
    /// Initializes a new route pattern with a pattern string and match closure.
    ///
    /// - Parameters:
    ///   - pattern: A readable identifier for the route (e.g. "/product/:id").
    ///   - match: A closure that takes `RouteParameters` and returns a `Route` if matched.
    public init(pattern: String, match: @escaping (RouteParameters) -> Route?) {
        self.pattern = pattern
        self.match = match
    }
}

/// Protocol that allows feature modules to provide their own route patterns.
///
/// Implement this protocol in each module that wants to register navigable routes.
public protocol RoutePatternProvider {
    
    /// List of all route patterns exposed by the feature module.
    static var routePatterns: [RoutePattern] { get }
}
