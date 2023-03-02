//
//  HeaderCheckingMiddlewareTests.swift
//  
//
//  Created by Joseph Wardell on 3/2/23.
//

@testable import App
import XCTVapor

final class HeaderCheckingMiddlewareTests: XCTestCase {

    private var sut: Application!
    
    override func setUp() {
        sut = Application(.testing)
        try! configure(sut)
   }
    
    override func tearDown() {
        sut.shutdown()
    }

    func test_get_responds_with_200() throws {
        try sut.test(.GET, HeaderCheckingMiddlewareTestsController.middleware_example) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_get_responds_with_empty_string_by_default() throws {
        try sut.test(.GET, HeaderCheckingMiddlewareTestsController.middleware_example) { response in
            let body = response.body.string
            XCTAssertEqual(body, "")
        }
    }
}