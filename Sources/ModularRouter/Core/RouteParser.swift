//
//  RouteParser.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Foundation

/// A concurrency-safe router that matches a path string against registered route patterns.
///
/// This class is used to parse incoming paths (e.g. from deep links or navigation)
/// and resolve them into concrete `Route` instances.
public struct RouteParser {
    
    /// Attempts to resolve a path (and query string) into a concrete `Route`.
    ///
    /// - Parameters:
    ///   - path: The raw path string to parse (e.g. "/product/42?sort=asc").
    ///   - baseURL: An optional base URL (scheme + host) used to parse query parameters. Default is `"myapp://"`.
    ///
    /// - Returns: A matched `Route` if found, or `.notFound(path)` if no match.
    public static func parse(path: String, baseURL: String = "myapp://") async -> Route {
        guard let url = URL(string: baseURL + path), url.scheme != nil else {
            return .notFound(path)
        }
        
        let components = Array(url.pathComponents.dropFirst())
        // Extract query items into a key-value map
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: String]()) { $0[$1.name] = $1.value } ?? [:]
        
        // Try matching each registered pattern
        for pattern in RouteRegistry.shared.allPatterns() {
            if let (params, _) = match(components: components, pattern: pattern.pattern) {
                let routeParams = RouteParameters(path: params, query: queryItems)
                if let route = pattern.match(routeParams) {
                    return route
                }
            }
        }
        
        return .notFound(path)
    }
    
    /// Matches an incoming URL path (split into components) against a pattern string.
    ///
    /// - Parameters:
    ///   - components: The incoming path components (e.g. ["product", "42"]).
    ///   - pattern: The registered route pattern (e.g. "/product/:id").
    ///
    /// - Returns: A tuple of matched path parameters and match result, or `nil` if unmatched.
    private static func match(components: [String], pattern: String) -> ([String: String], Bool)? {
        let patternParts = pattern.split(separator: "/").map(String.init)
        guard patternParts.count == components.count else { return nil }
        
        var params: [String: String] = [:]
        
        for (p, c) in zip(patternParts, components) {
            if p.hasPrefix(":") {
                params[String(p.dropFirst())] = c
            } else if p != c {
                return nil
            }
        }
        
        return (params, true)
    }
}
