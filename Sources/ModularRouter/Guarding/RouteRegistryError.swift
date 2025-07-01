//
//  RouteRegistryError.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

public enum RouteRegistryError: Error, CustomStringConvertible, Equatable {
    case duplicatePattern(String)
    
    public var description: String {
        switch self {
        case .duplicatePattern(let pattern):
            return "Route pattern '\(pattern)' is already registered."
        }
    }
}
