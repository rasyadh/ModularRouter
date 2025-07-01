//
//  RouteParameters.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Foundation

/// A container for extracted path and query parameters during route matching.
///
/// `RouteParameters` provides type-safe access to parameters parsed from a URL path
/// (e.g. `/product/:id`) or query string (`?sort=asc&limit=10`).
public struct RouteParameters: Sendable {
    
    /// Parameters parsed from path segments (e.g. `:id` in `/product/:id`).
    public let path: [String: String]
    
    /// Parameters parsed from the query string (e.g. `?sort=asc`).
    public let query: [String: String]
    
    /// Initializes a new `RouteParameters` instance.
    ///
    /// - Parameters:
    ///   - path: Key-value pairs from dynamic path components.
    ///   - query: Key-value pairs from query string.
    public init(path: [String: String] = [:], query: [String: String] = [:]) {
        self.path = path
        self.query = query
    }
    
    /// Returns a raw string value from path or query, prioritizing path.
    public func string(_ key: String) -> String? {
        path[key] ?? query[key]
    }
    
    /// Parses an `Int` from the value (if possible).
    public func int(_ key: String) -> Int? {
        string(key).flatMap(Int.init)
    }
    
    /// Parses a `Bool` from the value, matching "true"/"false" case-insensitively.
    public func bool(_ key: String) -> Bool? {
        string(key).flatMap {
            switch $0.lowercased() {
            case "true": return true
            case "false": return false
            default: return nil
            }
        }
    }
    
    /// Parses a `Double` from the value.
    public func double(_ key: String) -> Double? {
        string(key).flatMap(Double.init)
    }
    
    /// Parses a `Float` from the value.
    public func float(_ key: String) -> Float? {
        string(key).flatMap(Float.init)
    }
    
    /// Parses a `[String]` from a comma-separated string.
    public func stringArray(_ key: String) -> [String]? {
        string(key)?.split(separator: ",").map { String($0) }
    }
    
    /// Parses a `[Int]` from a comma-separated string.
    public func intArray(_ key: String) -> [Int]? {
        string(key)?.split(separator: ",").compactMap { Int($0) }
    }
    
    /// Parses a `[Double]` from a comma-separated string.
    public func doubleArray(_ key: String) -> [Double]? {
        string(key)?.split(separator: ",").compactMap { Double($0) }
    }
    
    /// Parses a `[Float]` from a comma-separated string.
    public func floatArray(_ key: String) -> [Float]? {
        string(key)?.split(separator: ",").compactMap { Float($0) }
    }
    
    /// Attempts to decode a JSON-encoded object from the parameter value.
    ///
    /// Useful for object parameters passed as stringified JSON.
    ///
    /// - Parameters:
    ///   - key: The parameter key.
    ///   - type: The expected `Decodable` type.
    /// - Returns: A decoded object if parsing and decoding succeed.
    public func decodedObject<T: Decodable>(_ key: String, as type: T.Type) -> T? {
        guard let json = string(key),
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
