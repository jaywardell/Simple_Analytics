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
    
    func test_get_responds_with_original_value_if_header_contains_required_key_and_value() throws {
        try sut.test(.GET, HeaderCheckingMiddlewareTestsController.middleware_example, headers: exampleHeaders) { response in
            let body = response.body.string
            XCTAssertEqual(body, "42")
        }
    }

    // MARK: - Helpers
    private var exampleHeaders: HTTPHeaders {
        HTTPHeaders([(HeaderCheckingMiddlewareTestsController.example_header_key, HeaderCheckingMiddlewareTestsController.example_header_value)])
    }
}
