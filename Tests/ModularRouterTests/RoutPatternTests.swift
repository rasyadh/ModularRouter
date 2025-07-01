//
//  RoutPatternTests.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import XCTest
@testable import ModularRouter

// Dummy provider for RoutePatternProvider
private struct DummyRoutes: RoutePatternProvider {
    static var routePatterns: [RoutePattern] {
        [
            RoutePattern(pattern: "/") { _ in
                    .wrapped(WrappedAppRoute(DummyRoute.example))
            },
            RoutePattern(pattern: "/example/:id") { params in
                guard let id = params.int("id") else { return nil }
                return .wrapped(WrappedAppRoute(DummyRoute.exampleDetail(id: id)))
            }
        ]
    }
}

final class RoutePatternTests: XCTestCase {
    
    func testStaticRoutePatternMatchesExample() {
        let pattern = DummyRoutes.routePatterns.first(where: { $0.pattern == "/" })!
        let match = pattern.match(RouteParameters())
        
        guard case let .wrapped(route)? = match else {
            return XCTFail("Route match failed for /")
        }
        
        XCTAssertEqual(route.path, "/")
    }
    
    func testDynamicRoutePatternMatchesExampleDetail() {
        let pattern = DummyRoutes.routePatterns.first(where: { $0.pattern == "/example/:id" })!
        let parameters = RouteParameters(path: ["id": "42"])
        
        let match = pattern.match(parameters)
        
        guard case let .wrapped(route)? = match else {
            return XCTFail("Route match failed for /example/:id")
        }
        
        XCTAssertEqual(route.path, "/example/42")
    }
    
    func testRoutePatternFailsOnMissingParameter() {
        let pattern = DummyRoutes.routePatterns.first(where: { $0.pattern == "/example/:id" })!
        let parameters = RouteParameters() // no "id"
        
        let match = pattern.match(parameters)
        XCTAssertNil(match, "Expected nil route when 'id' is missing")
    }
}

