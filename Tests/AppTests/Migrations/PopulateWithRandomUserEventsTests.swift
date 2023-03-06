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

    // really just makign sure that configure() reads the environment correctly
    func test_proper_environment_is_no_set_before_application_is_configured() throws {
        XCTAssertFalse(PopulateWithRandomUserEvents.hasRun)
    }

    // really just makign sure that configure() reads the environment correctly
    func test_proper_environment_is_set() throws {
        _ = try makeSUT()
        XCTAssert(PopulateWithRandomUserEvents.hasRun)
    }
}
