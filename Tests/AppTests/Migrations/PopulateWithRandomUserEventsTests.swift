//
//  PopulateWithRandomUserEventsTests.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

@testable import App
import XCTVapor
import SimpleAnalyticsTypes

final class PopulateWithRandomUserEventsTests: SimpleVaporTests {

    private static let env = Environment(name: PopulateWithRandomUserEvents.prepopulate, arguments: Environment.testing.arguments)
    override class var environment: Environment { env }

    
    // MARK: - Results of Prepopulation
    
    func test_populates_database() throws {
        let sut = try makeSUT()
                
        try sut.test(.GET, UsersController.countPath) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssert(received > 0)
        }
    }

    func test_populates_database_with_expected_count() throws {
        let sut = try makeSUT()
                
        try sut.test(.GET, countPath()) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, .prepopulatedEventCount)
        }
    }

    func test_populates_database_with_events_in_the_last_3_years() throws {
        let sut = try makeSUT()
                
        let now = Date()
        
        let threeYearsAgo = now.addingTimeInterval(-.prepopulatedTimeSpan)
        let endOfDay = Calendar.current.startOfDay(for: now.addingTimeInterval(.oneDay))
        try sut.test(.GET, countPath(startDate: threeYearsAgo, endDate: endOfDay)) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssertEqual(received, .prepopulatedEventCount)
        }
    }

    // MARK: - Helpers
    
    func countPath(startDate: Date? = nil,
                  endDate: Date? = nil,
                  userID: UUID? = nil,
                  action: UserEvent.Action? = nil,
                  flag: Bool? = nil) -> String {
        
        endpoint(UserEventsController.countPath, startDate: startDate, endDate: endDate, userID: userID, action: action, flag: flag)
    }

}
