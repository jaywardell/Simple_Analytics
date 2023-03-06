//
//  UserEventsControllerTest.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

@testable import App
import XCTVapor
import SimpleAnalyticsTypes

final class UserEventsControllerTest: SimpleVaporTests {

    // MARK: GET list -  list all UserEvents
    func test_get_list_returns_200() throws {
        let sut = try makeSUT()
        
        try sut.test(.GET, UserEventsController.listPath) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_get_list_returns_empty_array_if_no_userevents_have_been_created() throws {
        let sut = try makeSUT()

        try sut.test(.GET, listPath()) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(received, [])
        }
    }

    func test_get_list_returns_userevent_that_has_been_added() throws {
        let sut = try makeSUT()

        let sent = UserEvent(action: .start, userID: exampleUserID)
        let expected = [sent]

        try sut.post(sent)
        
        try sut.test(.GET, listPath()) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(received, expected)
        }
    }

    func test_get_list_returns_all_userevent_that_have_been_added() throws {
        let sut = try makeSUT()

        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }

        try sut.post(sent)
        
        try sut.test(.GET, listPath()) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            // use Sets since order doesn't matter
            XCTAssertEqual(Set(received), Set(sent))
        }
    }

    func test_get_list_returns_400_if_query_contains_unexpected_keys() throws {
        let sut = try makeSUT()

        let path = pathString(UserEventsController.listPath, adding: [("foo", "bar")])
        try sut.test(.GET, path) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }
    
    func test_get_list_returns_all_userevents_that_fit_in_date_range() throws {
        let sut = try makeSUT()

        let now = Date()
            
        let eventToday = UserEvent.random(at: now)
        
        try sut.post([
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
        let sut = try makeSUT()

        let now = Date()
            
        let eventToday = UserEvent.random(at: now)
        
        try sut.post(eventToday)
        
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        try sut.test(.GET, listPath(startDate: endOfDay, endDate: startOfDay)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(received, [])
        }
    }
    
    func test_get_list_returns_400_if_given_startDate_but_not_given_endDate() throws {
        let sut = try makeSUT()

        try sut.test(.GET, listPath(startDate: Date())) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_get_list_returns_400_if_given_endDate_but_not_given_startDate() throws {
        let sut = try makeSUT()

        try sut.test(.GET, listPath(endDate: Date())) { response in
            XCTAssertEqual(response.status, .badRequest)
        }
    }

    func test_get_list_returns_all_userevents_that_match_action_requested() throws {
        let sut = try makeSUT()

        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }

        let expected = sent.filter { $0.action == .pause }
        
        try sut.post(sent)
        
        try sut.test(.GET, listPath(action: .pause)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_returns_all_userevents_that_match_action_requested_and_fit_within_date_range() throws {
        let sut = try makeSUT()

        let now = Date()
        let dateRange: ClosedRange<TimeInterval> = -.oneDay ... .oneDay
        
        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: now.addingTimeInterval(.random(in: dateRange)))
        }

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        let expected = sent.filter {
            $0.action == .pause &&
            $0.timestamp >= startOfDay.timeIntervalSinceReferenceDate &&
            $0.timestamp <= endOfDay.timeIntervalSinceReferenceDate
        }
        
        try sut.post(sent)
        
        try sut.test(.GET, listPath(startDate: startOfDay, endDate: endOfDay, action: .pause)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_returns_all_userevents_that_match_userID_requested() throws {
        let sut = try makeSUT()

        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }

        let someEvent = sent.randomElement()!
        let filteredUserID = someEvent.userID
        
        let expected = sent.filter { $0.userID == filteredUserID }
        
        try sut.post(sent)
        
        try sut.test(.GET, listPath(userID: filteredUserID)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
            XCTAssert(received.count > 0)
        }
    }

    func test_get_list_returns_all_userevents_that_match_flag_requested() throws {
        let sut = try makeSUT()

        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }
        
        let expected = sent.filter { $0.flag == false }
        
        try sut.post(sent)
        
        try sut.test(.GET, listPath(flag: false)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_returns_all_userevents_that_match_flag_requested_true() throws {
        let sut = try makeSUT()

        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }
        
        let expected = sent.filter { $0.flag == true }
        
        try sut.post(sent)
        
        try sut.test(.GET, listPath(flag: true)) { response in
            let received = try JSONDecoder().decode([UserEvent].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_stress_test_send_all_query_keys() throws {
        let sut = try makeSUT()

        let now = Date()
        let dateRange: ClosedRange<TimeInterval> = -.oneDay ... .oneDay
        
        let sent = (0..<300).map { _ in
            UserEvent.random(at: now.addingTimeInterval(.random(in: dateRange)))
        }

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        
        let happeningToday = sent.filter {
            $0.timestamp >= startOfDay.timeIntervalSinceReferenceDate &&
            $0.timestamp <= endOfDay.timeIntervalSinceReferenceDate
        }
        
        let expected = happeningToday.randomElement()!
        
        try sut.post(sent)
        
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

    
    // MARK: GET count -
    func test_get_count_returns_200() throws {
        let sut = try makeSUT()

        try sut.test(.GET, UserEventsController.countPath) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }

    func test_get_count_returns_all_userevents_that_match_flag_requested_true() throws {
        let sut = try makeSUT()

        let sent = (0..<Int.random(in: 3..<20)).map { _ in
            UserEvent.random(at: Date().addingTimeInterval(.random(in: 60...3600)))
        }
        
        let expected = sent.filter { $0.flag == true }
        
        try sut.post(sent)
        
        try sut.test(.GET, countPath(flag: true)) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, expected.count)
        }
    }

    func test_get_count_stress_test_send_all_query_keys() throws {
        let sut = try makeSUT()

        let now = Date()
        let dateRange: ClosedRange<TimeInterval> = -.oneDay ... .oneDay
        
        let sent = (0..<300).map { _ in
            UserEvent.random(at: now.addingTimeInterval(.random(in: dateRange)))
        }

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        
        let happeningToday = sent.filter {
            $0.timestamp >= startOfDay.timeIntervalSinceReferenceDate &&
            $0.timestamp <= endOfDay.timeIntervalSinceReferenceDate
        }
        
        let expected = happeningToday.randomElement()!
        
        try sut.post(sent)
        
        let path = countPath(startDate: startOfDay,
                            endDate: endOfDay,
                            userID: expected.userID,
                            action: expected.action,
                            flag: expected.flag)
        try sut.test(.GET, path) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, 1)
        }
    }

    // MAKR: - Bad Requests
    func test_post_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.POST, UserEventsController.userevents, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_put_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.PUT, UserEventsController.userevents, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_delete_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.DELETE, UserEventsController.userevents, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    // MAKR: -
    func test_post_count_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.POST, countPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_put_count_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.PUT, countPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_delete_count_returns_404() throws {
        let sut = try makeSUT()

        try sut.test(.DELETE, countPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
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
    
    func countPath(startDate: Date? = nil,
                  endDate: Date? = nil,
                  userID: UUID? = nil,
                  action: UserEvent.Action? = nil,
                  flag: Bool? = nil) -> String {
        endpoint(UserEventsController.countPath, startDate: startDate, endDate: endDate, userID: userID, action: action, flag: flag)
    }

//    func post(_ userEvents: [UserEvent]) throws {
//        try userEvents.forEach {
//            _ = try sut.sendRequest(.POST, UserEventController.userevent, headers: HTTPHeaders.content_type_json, body: $0.toByteBuffer())
//        }
//    }
//
//    func post(_ userEvent: UserEvent) throws {
//        try post([userEvent])
//    }


}

