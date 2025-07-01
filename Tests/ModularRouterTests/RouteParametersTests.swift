//
//  RouteParametersTests.swift
//  ModularRouter
//
//  Created by Rasyadh Abdul Aziz on 01/07/25.
//

import XCTest
@testable import ModularRouter

final class RouteParametersTests: XCTestCase {
    
    func testPrimitiveValues() {
        let params = RouteParameters(path: ["id": "42"], query: [
            "name": "Swift",
            "active": "true",
            "rating": "4.5",
            "precision": "3.14"
        ])
        
        XCTAssertEqual(params.int("id"), 42)
        XCTAssertEqual(params.string("name"), "Swift")
        XCTAssertEqual(params.bool("active"), true)
        XCTAssertEqual(params.double("rating"), 4.5)
        XCTAssertEqual(params.float("precision"), Float(3.14))
    }
    
    func testArrayParsing() {
        let query: [String: String] = [
            "tags": "a,b,c",
            "scores": "1.1,2.2,3.3",
            "levels": "10,20,30",
            "percents": "0.1,0.5,0.9"
        ]
        let params = RouteParameters(query: query)
        
        XCTAssertEqual(params.stringArray("tags"), ["a", "b", "c"])
        XCTAssertEqual(params.doubleArray("scores"), [1.1, 2.2, 3.3])
        XCTAssertEqual(params.intArray("levels"), [10, 20, 30])
        XCTAssertEqual(params.floatArray("percents"), [0.1, 0.5, 0.9])
    }
    
    func testDecodedObject() {
        struct User: Decodable, Equatable {
            let name: String
            let age: Int
        }
        
        let jsonString = #"{"name":"Rasyadh","age":27}"#
        let params = RouteParameters(query: ["user": jsonString])
        
        let user = params.decodedObject("user", as: User.self)
        XCTAssertEqual(user, User(name: "Rasyadh", age: 27))
    }
    
    func testFallbackPriorityPathOverQuery() {
        let params = RouteParameters(path: ["id": "123"], query: ["id": "999"])
        XCTAssertEqual(params.int("id"), 123)
    }
    
    func testBoolEdgeCases() {
        let params = RouteParameters(query: ["flag1": "true", "flag2": "false", "flag3": "maybe"])
        XCTAssertEqual(params.bool("flag1"), true)
        XCTAssertEqual(params.bool("flag2"), false)
        XCTAssertNil(params.bool("flag3"))
    }
}
