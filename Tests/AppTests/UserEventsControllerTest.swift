//
//  UserEventsControllerTest.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

@testable import App
import XCTVapor

final class UserEventsControllerTest: XCTestCase {

    private var sut: Application!
    
    override func setUp() {
        sut = Application(.testing)
        try! configure(sut)
   }
    
    override func tearDown() {
        sut.shutdown()
    }

    // MARK: GET list -  list all UserEvents
    func test_get_list_returns_200() throws {
        try sut.test(.GET, UserEventsController.listPath) { response in
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
                
        let path = pathString(UserEventsController.listPath, adding: [("foo", "bar")])
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

    func test_get_list_returns_all_userevents_that_match_action_requested_and_fit_within_date_range() throws {
                
        let now = Date()
        let dateRange: ClosedRange<TimeInterval> = -.oneDay ... .oneDay
        
        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: now.addingTimeInterval(.random(in: dateRange)))
        }

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        let expected = sent.filter {
            $0.action == .pause &&
            $0.timestamp.value >= startOfDay &&
            $0.timestamp.value <= endOfDay
        }
        
        try post(sent)
        
        try sut.test(.GET, listPath(startDate: startOfDay, endDate: endOfDay, action: .pause)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_returns_all_userevents_that_match_userID_requested() throws {
                
        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }

        let someEvent = sent.randomElement()!
        let filteredUserID = someEvent.userID
        
        let expected = sent.filter { $0.userID == filteredUserID }
        
        try post(sent)
        
        try sut.test(.GET, listPath(userID: filteredUserID)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
            XCTAssert(received.count > 0)
        }
    }

    func test_get_list_returns_all_userevents_that_match_flag_requested() throws {
                
        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }
        
        let expected = sent.filter { $0.flag == false }
        
        try post(sent)
        
        try sut.test(.GET, listPath(flag: false)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_returns_all_userevents_that_match_flag_requested_true() throws {
                
        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }
        
        let expected = sent.filter { $0.flag == true }
        
        try post(sent)
        
        try sut.test(.GET, listPath(flag: true)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_stress_test_send_all_query_keys() throws {
                
        let now = Date()
        let dateRange: ClosedRange<TimeInterval> = -.oneDay ... .oneDay
        
        let sent = (0..<300).map { _ in
            UserEvent.random(at: now.addingTimeInterval(.random(in: dateRange)))
        }

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        
        let happeningToday = sent.filter {
            $0.timestamp.value >= startOfDay &&
            $0.timestamp.value <= endOfDay
        }
        
        let expected = happeningToday.randomElement()!
        
        try post(sent)
        
        let path = listPath(startDate: startOfDay,
                            endDate: endOfDay,
                            userID: expected.userID,
                            action: expected.action,
                            flag: expected.flag)
        try sut.test(.GET, path) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssert(received.contains(expected))
        }
    }

    // MARK: - Helpers

    private var exampleUserID: UUID { UUID() }
    
    func listPath(startDate: Date? = nil,
                  endDate: Date? = nil,
                  userID: UUID? = nil,
                  action: UserEvent.Action? = nil,
                  flag: Bool? = nil) -> String {
        endpoint(UserEventsController.listPath, startDate: startDate, endDate: endDate, userID: userID, action: action, flag: flag)
    }
    
    func post(_ userEvents: [UserEvent]) throws {
        try userEvents.forEach {
            _ = try sut.sendRequest(.POST, UserEventController.userevent, headers: HTTPHeaders.content_type_json, body: $0.toByteBuffer())
        }
    }

    func post(_ userEvent: UserEvent) throws {
        try post([userEvent])
    }


}

