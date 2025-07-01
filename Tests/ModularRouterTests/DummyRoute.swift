//
//  File.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

@testable import ModularRouter

public enum DummyRoute: AppRoute {
    case example
    case exampleDetail(id: Int)
    
    public var path: String {
        switch self {
        case .example: return "/"
        case .exampleDetail(let id): return "/example/\(id)"
        }
    }
}
