//
//  RouteParserTests.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import XCTest
@testable import ModularRouter

// Dummy provider for RoutePatternProvider
private struct DummyRoutesProvider: RoutePatternProvider {
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

final class StaticRouteTest: XCTestCase {
    
    func testMatchingStaticRoute() async throws {
        for pattern in DummyRoutesProvider.routePatterns {
            try? RouteRegistry.shared.register(pattern)
        }
        let route = await RouteParser.parse(path: "/")
        XCTAssertEqual(route.pathDescription, "/")
    }
}

final class RouteParserTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        for pattern in DummyRoutesProvider.routePatterns {
            try? RouteRegistry.shared.register(pattern)
        }
    }
    
    func testMatchingDynamicRoute() async {
        let route = await RouteParser.parse(path: "/example/42")
        XCTAssertEqual(route.pathDescription, "/example/42")
    }
    
    func testRouteNotFound() async {
        let route = await RouteParser.parse(path: "/unknown/path")
        XCTAssertEqual(route.pathDescription, "[NOT FOUND] /unknown/path")
    }
    
    func testInvalidURLHandling() async {
        let route = await RouteParser.parse(path: "/💣invalid@@")
        XCTAssertEqual(route.pathDescription, "[NOT FOUND] /💣invalid@@")
    }
    
    func testQueryParsing() async {
        let route = await RouteParser.parse(path: "/example/12?from=test")
        if case .wrapped(let wrapped) = route {
            XCTAssertEqual(wrapped.path, "/example/12")
        } else {
            XCTFail("Expected wrapped route")
        }
    }
    
    func testDuplicatePatternThrowsError() async throws {
        guard let pattern = DummyRoutesProvider.routePatterns.first else {
            XCTFail("Unexpected error")
            return
        }
        
        do {
            try RouteRegistry.shared.register(pattern)
            XCTFail("Expected duplicatePattern error")
        } catch let error as RouteRegistryError {
            XCTAssertEqual(error, .duplicatePattern(pattern.pattern))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
