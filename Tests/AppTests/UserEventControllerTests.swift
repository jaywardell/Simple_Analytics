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
    
    // MARK: POST -  add UserEvent
    func test_post_responds_with_200() async throws {

        try await testPOST(UserEvent(action: .start, userID: exampleUserID).toByteBuffer()) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_responds_with_empty_string_by_default() async throws {
        let sent = UserEvent(action: .start, userID: exampleUserID)
        try await testPOST(sent.toByteBuffer()) { response in
            XCTAssert(response.body.readableBytesView.isEmpty)
        }
    }
    
    func test_responds_with_values_if_verbose_is_true_in_headers() async throws {
        let sent = UserEvent(action: .start, userID: exampleUserID)
        try await testPOST(sent.toByteBuffer(),
                           headers: verboseHeaders
        ) { response in
            XCTAssert(!response.body.readableBytesView.isEmpty)
        }
    }

    func test_post_responds_with_UserEvent_that_was_passed_in() async throws {

        let expected = UserEvent(action: .start, userID: exampleUserID)
        try await testPOST(expected.toByteBuffer(), headers: verboseHeaders) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssertEqual(received, expected)
        }
    }

    func test_post_responds_with_UserEvent_with_same_flag_as_what_was_passed_in() async throws {

        let sent = UserEvent(action: .start, userID: exampleUserID, flag: true)
        try await testPOST(sent.toByteBuffer(), headers: verboseHeaders) { response in
            let received = try JSONDecoder().decode(UserEvent.self, from: response.body)
            XCTAssert(received.flag)
        }
    }

    func test_post_responds_with_UserEvent_with_same_action_as_what_was_passed_in() async throws {

        let sent = UserEvent(action: .pause, userID: exampleUserID, flag: true)
        try await testPOST(sent.toByteBuffer(), headers: verboseHeaders) { response in
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

    
    
    // MARK: GET list -  list all UserEvents
    func test_get_list_returns_200() throws {
        try sut.test(.GET, listPath()) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_get_list_returns_empty_array_if_no_userevents_have_been_created() throws {
        try sut.test(.GET, listPath()) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(received, [])
        }
    }

    func test_get_list_returns_userevent_that_has_been_added() throws {
                
        let sent = UserEvent(action: .start, userID: exampleUserID)
        let expected = [sent]

        try post(sent)
        
        try sut.test(.GET, listPath()) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(received, expected)
        }
    }

    func test_get_list_returns_all_userevent_that_have_been_added() throws {
                
        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }

        try post(sent)
        
        try sut.test(.GET, listPath()) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            // use Sets since order doesn't matter
            XCTAssertEqual(Set(received), Set(sent))
        }
    }

    func test_get_list_returns_400_if_query_contains_unexpected_keys() throws {
                
        let path = pathString(UserEventController.listPath, adding: [("foo", "bar")])
        try sut.test(.GET, path) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func test_get_list_returns_all_userevents_that_fit_in_date_range() throws {
                
        let now = Date()
            
        let eventToday = UserEvent.random(at: now)
        
        try post([
            UserEvent.random(at: now.addingTimeInterval(-.oneDay)),
            eventToday,
            UserEvent.random(at: now.addingTimeInterval(.oneDay))
        ])
        
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        try sut.test(.GET, listPath(startDate: startOfDay, endDate: endOfDay)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(received, [eventToday])
        }
    }

    func test_get_list_returns_empty_array_if_endDate_precedes_startDate() throws {
                
        let now = Date()
            
        let eventToday = UserEvent.random(at: now)
        
        try post(eventToday)
        
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        try sut.test(.GET, listPath(startDate: endOfDay, endDate: startOfDay)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(received, [])
        }
    }
    
    func test_get_list_returns_400_if_given_startDate_but_not_given_endDate() throws {
                
        try sut.test(.GET, listPath(startDate: Date())) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_get_list_returns_400_if_given_endDate_but_not_given_startDate() throws {
                
        try sut.test(.GET, listPath(endDate: Date())) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_get_list_returns_all_userevents_that_match_action_requested() throws {
                
        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }

        let expected = sent.filter { $0.action == .pause }
        
        try post(sent)
        
        try sut.test(.GET, listPath(action: .pause)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    // MARK: - Bad Requests
    
    func test_get_returns_404() throws {
        
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
    private var verboseHeaders: HTTPHeaders { HTTPHeaders(dictionaryLiteral:
        ("content-type", "application/json"),
        (UserEventController.verbose, UserEventController.verboseTrue)
    ) }

    private var exampleValidUserEventProperties: [String:Any] {
        [
            "userID": UUID().uuidString,
            "timestamp": Date().timeIntervalSinceReferenceDate.rounded(),
            "flag": true,
            "action": UserEvent.Action.start.rawValue
        ]
    }

    
    func pathString(_ path: String, adding queries: [(String, String)]) -> String {
        guard queries.count > 0 else { return path }
        return path + "?" + queries.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    func listPath(startDate: Date? = nil,
                  endDate: Date? = nil,
                  action: UserEvent.Action? = nil,
                  flag: Bool? = nil) -> String {
        var queries = [(String, String)]()
        if let startDate {
            queries.append((UserEventController.startDate, String(startDate.timeIntervalSinceReferenceDate)))
        }
        if let endDate {
            queries.append((UserEventController.endDate, String(endDate.timeIntervalSinceReferenceDate)))
        }
        if let action {
            queries.append((UserEventController.action, action.rawValue))
        }
        if let flag {
            queries.append((UserEventController.flag, String(flag)))
        }
        
        // shuffle the queries to ensure that the server is robust about how it handles queries in any order
        return pathString(UserEventController.listPath, adding: queries.shuffled())
    }
    
    func post(_ userEvents: [UserEvent]) throws {
        try userEvents.forEach {
            _ = try sut.sendRequest(.POST, UserEventController.userevents, headers: defaultHeaders, body: $0.toByteBuffer())
        }
    }

    func post(_ userEvent: UserEvent) throws {
        try post([userEvent])
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

    /// returns a UserEvent with all random properties except for a date at the date passed in.
    static func random(at date: Date) -> UserEvent {
        UserEvent(date: date, action: .allCases.randomElement()!, userID: .generateRandom(), flag: .random())
    }
}

fileprivate extension TimeInterval {
    static var oneDay: TimeInterval { 24*3600 }
}
