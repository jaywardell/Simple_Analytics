//
//  PopulateWithRandomUserEventsTests.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

@testable import App
import XCTVapor

final class PopulateWithRandomUserEventsTests: SimpleVaporTests {

    private static let env = Environment(name: Environment.testing.name, arguments: [PopulateWithRandomUserEvents.prepopulate])
    override class var environment: Environment { env }

    
    // MARK: - Results of Prepopulation
    
    func test_populates_database() throws {
        let sut = try makeSUT()
                
        try sut.test(.GET, UsersController.countPath) { response in
            let received = try JSONDecoder().decode(Int.self, from: response.body)
            XCTAssert(received > 0)
        }
    }

}
