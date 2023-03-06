//
//  UserControllerTests.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

@testable import App
import XCTVapor
import SimpleAnalyticsTypes

final class UserControllerTests: XCTestCase {
    
    private var sut: Application!
    
    override func setUp() {
        sut = Application(.testing)
        try! configure(sut)
   }
    
    override func tearDown() {
        sut.shutdown()
    }
    
    // MARK: - GET - list
    func test_get_list_returns_200() throws {
        try sut.test(.GET, UsersController.users) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_get_list_returns_all_users_that_have_used_app() throws {
                
        let userIDs = (0..<10).map { _ in UUID() }
        let expected = userIDs.map(\.uuidString)
        let sent = userIDs.map { UserEvent.random(for: $0, at: Date()) }
        try post(sent)
        
        try sut.test(.GET, UsersController.users) { response in
            let received = try JSONDecoder().decode([String].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_returns_each_user_that_has_used_app_once() throws {
        
        let user = UUID()
        
        let sent = (0..<10).map { _ in UserEvent.random(for: user, at: Date().addingTimeInterval(.random(in: 60..<3600))) }
        try post(sent)
        
        try sut.test(.GET, UsersController.users) { response in
            let received = try JSONDecoder().decode([String].self, from: response.body)
            XCTAssertEqual(received, [user.uuidString])
        }
    }

    // MARK: - GET - count
    
    func test_get_count_returns_200() throws {
        try sut.test(.GET, UsersController.countPath) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }

    func test_get_count_returns_count_of_users_that_have_used_app() throws {
        
        let users = (0..<Int.random(in: 3..<20)).map { _ in UUID() }

        // send twice so that each user has 2 events in the database
        try post(users.map { UserEvent.random(for: $0, at: Date()) })
        try post(users.map { UserEvent.random(for: $0, at: Date()) })

        try sut.test(.GET, UsersController.countPath) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, users.count)
        }
    }

    func test_get_count_returns_count_of_users_that_have_used_app_and_sent_a_given_action() throws {
        
        let user1 = UUID()
        let user2 = UUID()
        let user3 = UUID()
        let events = [
            UserEvent(date: Date(), action: .start, userID: user1),
            UserEvent(date: Date(), action: .start, userID: user1),
            UserEvent(date: Date(), action: .start, userID: user2),
            UserEvent(date: Date(), action: .start, userID: user2),
            UserEvent(date: Date(), action: .stop, userID: user3),
            UserEvent(date: Date(), action: .stop, userID: user3),
        ]
        try post(events)
        
        try sut.test(.GET, countPath(action: .start)) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(received, 2)
        }
    }

    func test_get_count_returns_count_of_all_users_that_used_app_in_date_range() throws {
                
        let now = Date()
            
        let users = [UUID(), UUID(), UUID()]
        
        let sent = users.flatMap { [
            UserEvent.random(for: $0, at: now.addingTimeInterval(-.oneDay)),
            UserEvent.random(for: $0, at: now),
            UserEvent.random(for: $0, at: now.addingTimeInterval(.oneDay))
        ]
        }
        
        try post(sent)
        
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        try sut.test(.GET, countPath(startDate: startOfDay, endDate: endOfDay)) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, users.count)
        }
    }
    
    func test_get_count_returns_count_of_all_users_that_have_had_flag_turned_on() throws {
                
        let now = Date()
            
        let users = (0..<30).map { _ in UUID() }
        
        let sent = users.map {
            UserEvent.random(for: $0, at: now)
        }
        let expected = sent.filter { $0.flag == true }.count

        try post(sent)
        
        
        try sut.test(.GET, countPath(flag: true)) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, expected)
        }
    }

    func test_get_count_returns_count_of_all_users_that_used_app_in_date_range_with_a_given_action() throws {
                
        let now = Date()
        let action = UserEvent.Action.pause

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))

        let users = (0..<30).map { _ in UUID() }
        
        let sent = users.flatMap { [
            UserEvent.random(for: $0, at: now.addingTimeInterval(-.oneDay)),
            UserEvent.random(for: $0, at: now),
            UserEvent.random(for: $0, at: now.addingTimeInterval(.oneDay))
        ]
        }
        
        let eventsWithActionOnDate = sent.filter { $0.action == action }
            .filter { $0.timestamp >= startOfDay.timeIntervalSinceReferenceDate }
            .filter { $0.timestamp <= endOfDay.timeIntervalSinceReferenceDate }
        let usersWhoSentAction = Set(eventsWithActionOnDate.map(\.userID))
        
        try post(sent)
        
        try sut.test(.GET, countPath(startDate: startOfDay, endDate: endOfDay, action: action)) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, usersWhoSentAction.count)
        }
    }

    // MARK: - GET - summary
    
    func test_get_summary_returns_200() throws {
        try sut.test(.GET, UsersController.summaryPath) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }

    func test_get_summary_returns_count_for_each_user_that_has_used_the_app() throws {
        
        let users = (0..<30).map { _ in UUID() }

        var counts = [String:Int]()
        for user in users {
            try (0..<Int.random(in: 0..<3)).forEach { _ in
                try post([UserEvent.random(for: user, at: Date().addingTimeInterval(.random(in: -1000 ... 1000)))])
                counts[user.uuidString] = counts[user.uuidString, default: 0] + 1
            }
        }
        
        try sut.test(.GET, summaryPath()) { response in
            let received = try JSONDecoder().decode([String:Int].self, from: response.body)
            XCTAssertEqual(received, counts)
        }
    }

    func test_get_summary_returns_count_for_each_user_that_has_used_the_app_and_passed_the_given_flag() throws {
        
        let users = (0..<30).map { _ in UUID() }
        let flag = true
        
        var counts = [String:Int]()
        for user in users {
            try (0..<Int.random(in: 0..<10)).forEach { _ in
                let event = UserEvent.random(for: user, at: Date().addingTimeInterval(.random(in: -.oneDay ... .oneDay)))
                try post([event])
                if event.flag == flag {
                    counts[user.uuidString] = counts[user.uuidString, default: 0] + 1
                }
            }
        }
        
        try sut.test(.GET, summaryPath(flag: flag)) { response in
            let received = try JSONDecoder().decode([String:Int].self, from: response.body)
            XCTAssertEqual(received, counts)
        }
    }

    func test_get_summary_returns_count_for_each_user_that_has_used_the_app_in_the_given_date_range() throws {
        
        let users = (0..<30).map { _ in UUID() }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))

        var counts = [String:Int]()
        for user in users {
            try (0..<Int.random(in: 0..<10)).forEach { _ in
                let event = UserEvent.random(for: user, at: Date().addingTimeInterval(.random(in: -.oneDay ... .oneDay)))
                try post([event])
                if event.timestamp >= startOfDay.timeIntervalSinceReferenceDate && event.timestamp <= endOfDay.timeIntervalSinceReferenceDate {
                    counts[user.uuidString] = counts[user.uuidString, default: 0] + 1
                }
            }
        }
        
        try sut.test(.GET, summaryPath(startDate: startOfDay, endDate: endOfDay)) { response in
            let received = try JSONDecoder().decode([String:Int].self, from: response.body)
            XCTAssertEqual(received, counts)
        }
    }

    // MARK: - Bad Requests
    
    func test_post_returns_404() throws {
        
        try sut.test(.POST, UsersController.users, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_put_returns_404() throws {

        try sut.test(.PUT, UsersController.users, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_delete_returns_404() throws {

        try sut.test(.DELETE, UsersController.users, afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    // MARK: - count
    
    func test_post_count_returns_404() throws {
        
        try sut.test(.POST, countPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_put_count_returns_404() throws {

        try sut.test(.PUT, countPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_delete_count_returns_404() throws {

        try sut.test(.DELETE, countPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    // MARK: - summary

    func test_post_summary_returns_404() throws {
        
        try sut.test(.POST, summaryPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_put_summary_returns_404() throws {

        try sut.test(.PUT, summaryPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    func test_delete_summary_returns_404() throws {

        try sut.test(.DELETE, summaryPath(), afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

    // MARK: - Helpers
    
    func post(_ userEvents: [UserEvent]) throws {
        try userEvents.forEach {
            _ = try sut.sendRequest(.POST, UserEventController.userevent, headers: .content_type_json, body: $0.toByteBuffer())
        }
    }
    
    func countPath(startDate: Date? = nil,
                  endDate: Date? = nil,
                  userID: UUID? = nil,
                  action: UserEvent.Action? = nil,
                  flag: Bool? = nil) -> String {
        
        endpoint(UsersController.countPath, startDate: startDate, endDate: endDate, userID: userID, action: action, flag: flag)
    }

    func summaryPath(startDate: Date? = nil,
                  endDate: Date? = nil,
                  userID: UUID? = nil,
                  action: UserEvent.Action? = nil,
                  flag: Bool? = nil) -> String {
 
        endpoint(UsersController.summaryPath, startDate: startDate, endDate: endDate, userID: userID, action: action, flag: flag)
    }
}
