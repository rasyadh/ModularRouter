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
        try? await RouteParser.register(DummyRoutesProvider.routePatterns)
        let route = await RouteParser.parse(path: "/")
        XCTAssertEqual(route.pathDescription, "/")
    }
}

final class RouteParserTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        Task {
            try? await RouteParser.register(DummyRoutesProvider.routePatterns)
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
        do {
            try await RouteParser.register(DummyRoutesProvider.routePatterns)
            XCTFail("Expected duplicatePattern error")
        } catch let error as RouteParserError {
            XCTAssertEqual(error, .duplicatePattern("/"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
