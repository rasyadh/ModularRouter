//
//  RouteRegistryTests.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import XCTest
@testable import ModularRouter

final class RouteRegistryTests: XCTestCase {
    
    override func setUp() async throws {
        // Reset the registry for clean test state
        await MainActor.run {
            RouteRegistry.shared.reset()
        }
    }
    
    func testSuccessfulRouteRegistration() throws {
        let pattern = RoutePattern(pattern: "/") { _ in
                .wrapped(WrappedAppRoute(DummyRoute.example))
        }
        
        try RouteRegistry.shared.register(pattern)
        
        let all = RouteRegistry.shared.allPatterns()
        XCTAssertTrue(all.contains(where: { $0.pattern == "/" }))
    }
    
    func testDuplicatePatternThrowsError() {
        let pattern = RoutePattern(pattern: "/") { _ in
                .wrapped(WrappedAppRoute(DummyRoute.example))
        }
        
        XCTAssertNoThrow(try RouteRegistry.shared.register(pattern))
        
        XCTAssertThrowsError(try RouteRegistry.shared.register(pattern)) { error in
            guard case RouteRegistryError.duplicatePattern(let path) = error else {
                return XCTFail("Expected .duplicatePattern but got \(error)")
            }
            XCTAssertEqual(path, "/")
        }
    }
}
