//
//  RouteGuard.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Foundation

public protocol RouteGuard {
    func shouldAllow(route: any AppRoute, parameters: RouteParameters) async -> RouteGuardResult
}

public enum RouteGuardResult {
    case allow
    case redirect(to: any AppRoute)
    case deny
}
