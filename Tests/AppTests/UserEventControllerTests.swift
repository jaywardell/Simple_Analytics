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
    
    func test_post_responds_with_200() async throws {

        try await testPOST(UserEvent(action: .start, userID: exampleUserID).toByteBuffer()) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_post_responds_with_UserEvent_that_was_passed_in() async throws {

        let expected = UserEvent(action: .start, userID: exampleUserID)
        try await testPOST(expected.toByteBuffer()) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssertEqual(received, expected)
        }
    }

    func test_post_responds_with_UserEvent_with_same_flag_as_what_was_passed_in() async throws {

        let sent = UserEvent(action: .start, userID: exampleUserID, flag: true)
        try await testPOST(sent.toByteBuffer()) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssert(received.flag)
        }
    }

    func test_post_responds_with_UserEvent_with_same_action_as_what_was_passed_in() async throws {

        let sent = UserEvent(action: .pause, userID: exampleUserID, flag: true)
        try await testPOST(sent.toByteBuffer()) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssertEqual(received.action, sent.action)
        }
    }

    
    func test_post_responds_with_200_if_given_valid_json() async throws {
                
        let data = try JSONSerialization.data(withJSONObject: exampleValidUserEventProperties)
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }

    func test_post_responds_with_400_if_given_unexpected_action() async throws {
        
        var invalidActionProperties = exampleValidUserEventProperties
        invalidActionProperties["action"] = "something unexpected"
        let data = try JSONSerialization.data(withJSONObject: invalidActionProperties)
        
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func test_post_responds_with_200_if_given_unexpected_extra_data_in_payload() async throws {
        
        var propertiesWithExtraValues = exampleValidUserEventProperties
        propertiesWithExtraValues["some_other_key"] = "some_invalid_value"
        let data = try JSONSerialization.data(withJSONObject: propertiesWithExtraValues)
        
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_post_responds_with_400_if_not_given_userID_in_payload() async throws {
        
        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "userID")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_not_given_id_in_payload() async throws {
        
        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "id")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_not_given_flag_in_payload() async throws {
        
        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "flag")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_not_given_timestamp_in_payload() async throws {
        
        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "timestamp")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_not_given_action_in_payload() async throws {
        
        var propertiesWithMissingValues = exampleValidUserEventProperties
        propertiesWithMissingValues.removeValue(forKey: "action")
        let data = try JSONSerialization.data(withJSONObject: propertiesWithMissingValues)
        
        try await testPOST(ByteBuffer(data: data)) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_422_if_body_is_empty_string() async throws {

        try await testPOST(ByteBuffer(string: "")) { response in
            XCTAssertEqual(response.status, .unprocessableEntity)
        }
    }

    func test_post_responds_with_400_if_body_is_unexpected_string() async throws {

        try await testPOST(ByteBuffer(string: "something unexpected")) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_400_if_body_is_empty_json() async throws {

        try await testPOST(ByteBuffer(string: "{}")) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_post_responds_with_415_if_given_no_headers() async throws {

        let expected = UserEvent(action: .start, userID: exampleUserID)
        try await testPOST(expected.toByteBuffer(), headers: HTTPHeaders()) { response in
            XCTAssertEqual(response.status, .unsupportedMediaType)
        }
    }

    
    func test_get_with_no_body_returns_404() throws {
        
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

    private var exampleUserID: UUID { UUID() }
    private var defaultHeaders: HTTPHeaders { HTTPHeaders(dictionaryLiteral: ("content-type", "application/json")) }
    
    private var exampleValidUserEventProperties: [String:Any] {
        [
            "id": UUID().uuidString,
            "userID": UUID().uuidString,
            "timestamp": Date().timeIntervalSinceReferenceDate.rounded(),
            "flag": true,
            "action": UserEvent.Action.start.rawValue
        ]
    }

    private func testPOST(_ byteBuffer: ByteBuffer,
                         headers: HTTPHeaders? = nil,
                         tests: (XCTHTTPResponse) async throws ->(),
                         file: StaticString = #filePath, line: UInt = #line) async throws {
        try await sut.test(.POST, UserEventController.userevents, headers: headers ?? defaultHeaders, body: byteBuffer, afterResponse: tests)
    }
}

// MARK: - UserEvent: Helpers

fileprivate extension UserEvent {
    func toByteBuffer() -> ByteBuffer {
        try! JSONEncoder().encodeAsByteBuffer(self, allocator: .init())
    }
}
