//
//  RouterTests.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import XCTest
@testable import ModularRouter

@MainActor
final class RouterTests: XCTestCase {
    
    struct TestRoute: AppRoute {
        let id: Int
        
        var path: String { "/test/\(id)" }
        var pattern: String { "/test/:id" }
    }
    
    struct AllowGuard: RouteGuard {
        func shouldAllow(route: any AppRoute, parameters: RouteParameters) async -> RouteGuardResult {
            .allow
        }
    }
    
    struct DenyGuard: RouteGuard {
        func shouldAllow(route: any AppRoute, parameters: RouteParameters) async -> RouteGuardResult {
            .deny
        }
    }
    
    struct RedirectGuard: RouteGuard {
        func shouldAllow(route: any AppRoute, parameters: RouteParameters) async -> RouteGuardResult {
            if let route = route as? TestRoute, route.id == 202 {
                return .allow
            } else {
                return .redirect(to: TestRoute(id: 202))
            }
        }
    }
    
    override func setUp() async throws {
        RouteRegistry.shared.reset()
    }
    
    func testGoAppendsRouteIfAllowed() async  throws {
        let router = Router()
        
        let pattern = RoutePattern(pattern: "/test/:id") { params in
            guard let id = params.int("id") else { return nil }
            return .wrapped(WrappedAppRoute(TestRoute(id: id)))
        }
        
        try RouteRegistry.shared.register(pattern, guard: AllowGuard())
        
        await router.navigate(to: .wrapped(WrappedAppRoute(TestRoute(id: 42))))
        
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first?.pathDescription, "/test/42")
    }
    
    func testGoDoesNotAppendIfDenied() throws {
        let router = Router()
        
        let pattern = RoutePattern(pattern: "/test/:id") { params in
            guard let id = params.int("id") else { return nil }
            return .wrapped(WrappedAppRoute(TestRoute(id: id)))
        }
        
        try RouteRegistry.shared.register(pattern, guard: DenyGuard())
        
        router.go(to: .wrapped(WrappedAppRoute(TestRoute(id: 13))))
        
        XCTAssertEqual(router.path.count, 0)
    }
    
    func testGoRedirectsIfGuardRedirects() async throws {
        let router = Router()
        
        let pattern = RoutePattern(pattern: "/test/:id") { params in
            guard let id = params.int("id") else { return nil }
            return .wrapped(WrappedAppRoute(TestRoute(id: id)))
        }
        
        try RouteRegistry.shared.register(pattern, guard: RedirectGuard())
        try RouteRegistry.shared.register(RoutePattern(pattern: "/test/202") { _ in
                .wrapped(WrappedAppRoute(TestRoute(id: 202)))
        })
        
        await router.navigate(to: .wrapped(WrappedAppRoute(TestRoute(id: 7))))
        
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first?.pathDescription, "/test/202")
    }
    
    func testGoBackPopsLastRoute() {
        let router = Router()
        router.path = [
            .wrapped(WrappedAppRoute(TestRoute(id: 1))),
            .wrapped(WrappedAppRoute(TestRoute(id: 2))),
        ]
        router.goBack()
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first?.pathDescription, "/test/1")
    }
    
    func testPopToRootKeepsOnlyFirst() {
        let router = Router()
        router.path = [
            .wrapped(WrappedAppRoute(TestRoute(id: 1))),
            .wrapped(WrappedAppRoute(TestRoute(id: 2))),
            .wrapped(WrappedAppRoute(TestRoute(id: 3)))
        ]
        router.popToRoot()
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first?.pathDescription, "/test/1")
    }
    
    func testResetOverridesStack() {
        let router = Router()
        router.path = [
            .wrapped(WrappedAppRoute(TestRoute(id: 1))),
            .wrapped(WrappedAppRoute(TestRoute(id: 2)))
        ]
        router.reset(to: .wrapped(WrappedAppRoute(TestRoute(id: 99))))
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first?.pathDescription, "/test/99")
    }
    
    func testOpenDeeplinkParsesAndResets() async throws {
        let router = Router()
        
        try RouteRegistry.shared.register(RoutePattern(pattern: "/test/:id") { params in
            guard let id = params.int("id") else { return nil }
            return .wrapped(WrappedAppRoute(TestRoute(id: id)))
        })
        
        await router.open(deeplink: "/test/5")
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first?.pathDescription, "/test/5")
    }
}
