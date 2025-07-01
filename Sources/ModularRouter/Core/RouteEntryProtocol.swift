//
//  RouteEntryProtocol.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import SwiftUI

public protocol RouteEntry {
    
    static func routePatterns() -> [RoutePattern]
    
    @ViewBuilder
    static func view(for route: any AppRoute, using router: Router) -> any View
}
