//
//  RequiresQueryMiddlewareTests.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

@testable import App
import XCTVapor

// TODO: use this in query endpoints to ensure that requests include headrs
final class RequiresQueryMiddlewareTests: XCTestCase {
    
    private var sut: Application!
    
    override func setUp() {
        sut = Application(.testing)
        try! configure(sut)
    }
    
    override func tearDown() {
        sut.shutdown()
    }
    
    func test_get_responds_with_400_if_no_query() throws {
        try sut.test(.GET, RequiresQueryMiddlewareTestsController.middleware_example) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func test_get_responds_with_200_if_includes_query() throws {
        try sut.test(.GET, pathString(RequiresQueryMiddlewareTestsController.middleware_example, adding: [("foo", "bar")])) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }

}
