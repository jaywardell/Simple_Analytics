//
//  UserControllerTests.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

@testable import App
import XCTVapor

final class UserControllerTests: XCTestCase {
    
    private var sut: Application!
    
    override func setUp() {
        sut = Application(.testing)
        try! configure(sut)
   }
    
    override func tearDown() {
        sut.shutdown()
    }
    
    // MARK: GET -
    func test_get_list_returns_200() throws {
        try sut.test(.GET, UserController.users) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
    
    func test_get_list_returns_all_users_that_have_used_app() throws {
                
        let userIDs = [UUID(), UUID(), UUID()]
        let expected = userIDs.map(\.uuidString)
        let sent = userIDs.map { UserEvent.random(for: $0, at: Date()) }
        try post(sent)
        
        try sut.test(.GET, UserController.users) { response in
            let received = try JSONDecoder().decode([String].self, from: response.body)
            XCTAssertEqual(Set(received), Set(expected))
        }
    }

    func test_get_list_returns_each_user_that_has_used_app_once() throws {
        
        let user = UUID()
        
        let sent = (0..<10).map { _ in UserEvent.random(for: user, at: Date().addingTimeInterval(.random(in: 60..<3600))) }
        try post(sent)
        
        try sut.test(.GET, UserController.users) { response in
            let received = try JSONDecoder().decode([String].self, from: response.body)
            XCTAssertEqual(received, [user.uuidString])
        }
    }

    func test_get_count_returns_count_of_users_that_have_used_app() throws {
        
        let users = (0..<Int.random(in: 3..<20)).map { _ in UUID() }

        // send twice so that each user has 2 events in the database
        try post(users.map { UserEvent.random(for: $0, at: Date()) })
        try post(users.map { UserEvent.random(for: $0, at: Date()) })

        try sut.test(.GET, UserController.countPath) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, users.count)
        }
    }

    // MARK: - Helpers
    
    private var defaultHeaders: HTTPHeaders { HTTPHeaders(dictionaryLiteral: ("content-type", "application/json")) }

    func post(_ userEvents: [UserEvent]) throws {
        try userEvents.forEach {
            _ = try sut.sendRequest(.POST, UserEventController.userevents, headers: defaultHeaders, body: $0.toByteBuffer())
        }
    }
}

// MARK: - UserEvent: Helpers

fileprivate extension UserEvent {
    func toByteBuffer() -> ByteBuffer {
        try! JSONEncoder().encodeAsByteBuffer(self, allocator: .init())
    }

    /// returns a UserEvent with all random properties except for a date at the date passed in.
    static func random(for userID: UUID, at date: Date) -> UserEvent {
        UserEvent(date: date, action: .allCases.randomElement()!, userID: userID, flag: .random())
    }
}

fileprivate extension TimeInterval {
    static var oneDay: TimeInterval { 24*3600 }
}
