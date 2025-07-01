//
//  Router.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Combine
import SwiftUI

/// A main-actor observable router that manages the navigation path
/// and enforces guard checks for secure or restricted routes.
@MainActor
public final class Router: ObservableObject, RouterProtocol {
    
    /// The current navigation stack of routes, used with `NavigationStack`.
    @Published public var path: [Route] = []
    
    /// Initializes a new `Router` instance.
    public init() {}
    
    
    /// Navigates to a new route after evaluating any associated guard.
    ///
    /// - Parameter route: The route to navigate to.
    public func go(to route: Route) {
        Task {
            await navigate(to: route)
        }
    }
    
    /// Navigates to a new route, handling guard logic and redirects if needed.
    ///
    /// - Parameter route: The resolved or constructed route to push.
    public func navigate(to route: Route) async {
        switch route {
        case .notFound:
            path.append(route)
            
        case .wrapped(let wrapped):
            // Check for registered guard
            if let routeGuard = RouteRegistry.shared.routeGuard(for: wrapped) {
                let result = await routeGuard.shouldAllow(
                    route: wrapped.base,
                    parameters: .init() // You can customize parameter injection here
                )
                switch result {
                case .allow:
                    path.append(route)
                case .redirect(let redirectRoute):
                    await navigate(to: .wrapped(WrappedAppRoute(redirectRoute)))
                case .deny:
                    // Do nothing
                    return
                }
            } else {
                // No guard; allow by default
                path.append(route)
            }
        }
    }
    
    /// Pops the last route off the stack, if not at root.
    public func goBack() {
        guard path.count > 1 else { return }
        _ = path.removeLast()
    }
    
    /// Pops all routes except the root.
    public func popToRoot() {
        guard let root = path.first else { return }
        path = [root]
    }
    
    /// Resets the stack to a single route.
    ///
    /// - Parameter route: The route to set as the only item on the stack.
    public func reset(to route: Route = .notFound("/")) {
        path = [route]
    }
    
    /// Opens a raw path (deeplink), resolves it to a `Route`, and resets the stack.
    ///
    /// - Parameter deeplink: The string path (e.g., "/product/42")
    public func open(deeplink: String) async {
        let route = await RouteParser.parse(path: deeplink)
        reset(to: route)
    }
}
