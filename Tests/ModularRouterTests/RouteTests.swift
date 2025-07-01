//
//  RouteTests.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import XCTest
@testable import ModularRouter

final class RouteTests: XCTestCase {
    
    // MARK: - Equality & Hashable
    
    func testWrappedAppRouteEquality() {
        let routeA = WrappedAppRoute(DummyRoute.exampleDetail(id: 42))
        let routeB = WrappedAppRoute(DummyRoute.exampleDetail(id: 42))
        let routeC = WrappedAppRoute(DummyRoute.exampleDetail(id: 7))
        
        XCTAssertEqual(routeA, routeB)
        XCTAssertNotEqual(routeA, routeC)
    }
    
    func testWrappedAppRouteHashable() {
        let route1 = WrappedAppRoute(DummyRoute.example)
        let route2 = WrappedAppRoute(DummyRoute.exampleDetail(id: 99))
        
        let set: Set<WrappedAppRoute> = [route1, route2]
        
        XCTAssertTrue(set.contains(route1))
        XCTAssertTrue(set.contains(route2))
    }
    
    // MARK: - Path Description
    
    func testRoutePathDescription() {
        let wrapped = Route.wrapped(WrappedAppRoute(DummyRoute.exampleDetail(id: 12)))
        let notFound = Route.notFound("/bad/path")
        
        XCTAssertEqual(wrapped.pathDescription, "/example/12")
        XCTAssertEqual(notFound.pathDescription, "[NOT FOUND] /bad/path")
    }
    
    // MARK: - Sendable Concurrency
    
    func testWrappedAppRouteIsSendableInTask() async  {
        let route = WrappedAppRoute(DummyRoute.exampleDetail(id: 10))
        let result = await Task.detached {
            return route.path
        }.value
        
        XCTAssertEqual(result, "/example/10")
    }
    
    func testRouteIsSendableInTask() async {
        let route: Route = .wrapped(WrappedAppRoute(DummyRoute.exampleDetail(id: 99)))
        let result = await Task.detached {
            return route.pathDescription
        }.value
        
        XCTAssertEqual(result, "/example/99")
    }
    
    // MARK: - Simulated Deep Link Decoding
    
    func testManualRouteDecodingFromPath() {
        let path = "/example/42"
        if path.starts(with: "/example/"),
           let idString = path.split(separator: "/").last,
           let id = Int(idString) {
            let route = DummyRoute.exampleDetail(id: id)
            XCTAssertEqual(route.path, path)
        } else {
            XCTFail("Path decoding failed")
        }
    }
}
