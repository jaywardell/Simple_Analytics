//
//  UserEventControllerTests.swift
//  
//
//  Created by Joseph Wardell on 2/28/23.
//

@testable import App
import XCTVapor
import SimpleAnalyticsTypes

final class UserEventControllerTests: SimpleVaporTests {
    
    // MARK: POST -  add UserEvent
    func test_post_responds_with_200() async throws {
        let sut = try makeSUT()
        
        try await sut.testPOST(UserEvent(action: .start, userID: exampleUserID).toByteBuffer()) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_responds_with_empty_string_by_default() async throws {
        let sut = try makeSUT()
        
        let sent = UserEvent(action: .start, userID: exampleUserID)
        try await sut.testPOST(sent.toByteBuffer()) { response in
            XCTAssert(response.body.readableBytesView.isEmpty)
        }
    }
    
    func test_responds_with_values_if_verbose_is_true_in_headers() async throws {
        let sut = try makeSUT()
        
        let sent = UserEvent(action: .start, userID: exampleUserID)
        try await sut.testPOST(sent.toByteBuffer(),
                           headers: verboseHeaders
        ) { response in
            XCTAssert(!response.body.readableBytesView.isEmpty)
        }
    }

    func test_post_responds_with_UserEvent_that_was_passed_in() async throws {
        let sut = try makeSUT()
        
        let expected = UserEvent(action: .start, userID: exampleUserID)
        try await sut.testPOST(expected.toByteBuffer(), headers: verboseHeaders) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssertEqual(received, expected)
        }
    }

    func test_post_responds_with_UserEvent_with_same_flag_as_what_was_passed_in() async throws {
        let sut = try makeSUT()
        

        let sent = UserEvent(action: .start, userID: exampleUserID, flag: true)
        try await sut.testPOST(sent.toByteBuffer(), headers: verboseHeaders) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssert(received.flag)
        }
    }

    func test_post_responds_with_UserEvent_with_same_action_as_what_was_passed_in() async throws {
        let sut = try makeSUT()
        
        let sent = UserEvent(action: .pause, userID: exampleUserID, flag: true)
        try await sut.testPOST(sent.toByteBuffer(), headers: verboseHeaders) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssertEqual(received.action, sent.action)
        }
    }

    
    func test_post_responds_with_200_if_given_valid_json() async throws {
        let sut = try makeSUT()
        
        let data = try JSONSerialization.data(withJSONObject: exampleValidUserEventProperties)
        try await sut.testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }

    func test_post_responds_with_400_if_given_unexpected_action() async throws {
        let sut = try makeSUT()

        var invalidActionProperties = exampleValidUserEventProperties
        invalidActionProperties["action"] = "something unexpected"
        let data = try JSONSerialization.data(withJSONObject: invalidActionProperties)
        
        try await sut.testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func test_post_responds_with_200_if_given_unexpected_extra_data_in_payload() async throws {
        let sut = try makeSUT()

        var propertiesWithExtraValues = exampleValidUserEventProperties
        propertiesWithExtraValues["some_other_key"] = "some_invalid_value"
        let data = try JSONSerialization.data(withJSONObject: propertiesWithExtraValues)
        
        try await sut.testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_post_responds_with_400_if_not_given_userID_in_payload() async throws {
        let sut = try makeSUT()

        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "userID")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await sut.testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_not_given_flag_in_payload() async throws {
        let sut = try makeSUT()

        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "flag")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await sut.testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_not_given_timestamp_in_payload() async throws {
        let sut = try makeSUT()

        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "timestamp")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await sut.testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_not_given_action_in_payload() async throws {
        let sut = try makeSUT()

        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "action")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await sut.testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_422_if_body_is_empty_string() async throws {
        let sut = try makeSUT()

        try await sut.testPOST(ByteBuffer(string: "")) { response in
            XCTAssertEqual(response.status, .unprocessableEntity)
        }
    }

    func test_post_responds_with_400_if_body_is_unexpected_string() async throws {
        let sut = try makeSUT()

        try await sut.testPOST(ByteBuffer(string: "something unexpected")) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_body_is_empty_json() async throws {
        let sut = try makeSUT()

        try await sut.testPOST(ByteBuffer(string: "{}")) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_415_if_given_no_headers() async throws {
        let sut = try makeSUT()

        let expected = UserEvent(action: .start, userID: exampleUserID)
        try await sut.testPOST(expected.toByteBuffer(), headers: HTTPHeaders()) { response in
            XCTAssertEqual(response.status, .unsupportedMediaType)
        }
    }

    
    

    
    // MARK: - Bad Requests
    
    func test_get_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.GET, UserEventController.userevent, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_put_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.PUT, UserEventController.userevent, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_delete_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.DELETE, UserEventController.userevent, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    
    // MARK: - Helpers

    private var exampleUserID: UUID { UUID() }
    private var verboseHeaders: HTTPHeaders {
        .content_type_json
        .verbose()
    }

    private var exampleValidUserEventProperties: [String:Any] {
        [
            UserEventsController.userID: UUID().uuidString,
            UserEventsController.timestamp: Date().timeIntervalSinceReferenceDate.rounded(),
            UserEventsController.flag: true,
            UserEventsController.action: UserEvent.Action.start.rawValue
        ]
    }


}

// MARK: -

fileprivate extension Application {
  
    func testPOST(_ byteBuffer: ByteBuffer,
                         headers: HTTPHeaders? = nil,
                         tests: (XCTHTTPResponse) async throws ->(),
                         file: StaticString = #filePath, line: UInt = #line) async throws {
        try await test(.POST, UserEventController.userevent, headers: headers ?? .content_type_json, body: byteBuffer, afterResponse: tests)
    }
}
