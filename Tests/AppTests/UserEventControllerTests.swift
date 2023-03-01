//
//  UserEventControllerTests.swift
//  
//
//  Created by Joseph Wardell on 2/28/23.
//

@testable import App
import XCTVapor

final class UserEventControllerTests: XCTestCase {

    private var sut: Application!
    
    override func setUp() {
        sut = Application(.testing)
        try! configure(sut)
   }
    
    override func tearDown() {
        sut.shutdown()
    }
    
    func test_post_responds_with_200() throws {

        try sut.test(.POST, UserEventController.userevents, headers: headers, body: UserEvent().toByteBuffer()) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_post_responds_with_UserEvent_that_was_passed_in() throws {

        let expected = UserEvent()
        try sut.test(.POST, UserEventController.userevents, headers: headers, body: expected.toByteBuffer()) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssertEqual(received, expected)
        }
    }

    
    func test_get_with_no_query_returns_404() throws {
        
        try sut.test(.GET, UserEventController.userevents, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_put_returns_404() throws {

        try sut.test(.PUT, UserEventController.userevents, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_delete_returns_404() throws {

        try sut.test(.DELETE, UserEventController.userevents, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }
    
    // MARK: - Helpers

    private var headers: HTTPHeaders { HTTPHeaders(dictionaryLiteral: ("content-type", "application/json")) }
}

// MARK: - UserEvent: Helpers

fileprivate extension UserEvent {
    func toByteBuffer() -> ByteBuffer {
        try! JSONEncoder().encodeAsByteBuffer(self, allocator: .init())
    }
}
