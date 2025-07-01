//
//  RouterProtocol.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import Foundation

@MainActor
public protocol RouterProtocol: AnyObject, Sendable {
    
    var path: [Route] { get set }
    
    func go(to route: Route)
    func reset(to route: Route)
    func open(deeplink: String) async
}
