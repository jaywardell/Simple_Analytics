//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

import Vapor
import FluentKit
import SimpleAnalyticsTypes

extension Int {
    static var prepopulatedUserCount: Int { 10 }
    static var prepopulatedEventCount: Int { 100 }
}

extension TimeInterval {
    static var prepopulatedTimeSpan: TimeInterval { 24*2600*365*3 }
}

// MARK: -

final class PopulateWithRandomUserEvents: AsyncMigration {
            
    @Environment.Key("count", .prepopulatedEventCount) var count: Int
    @Environment.Key("users", .prepopulatedUserCount) var userCount: Int
    @Environment.Key("timespan", .prepopulatedTimeSpan) var timespan: TimeInterval

    static var prepopulate: String { "prepopulate_with_random" }
    static var prepopulateCount: Int { 10_000 }
    static var timeSpan: TimeInterval { 24*2600*365*3 }
    private var createEventIDs = [UUID]()
    
    static func shouldPrepopulate(for app: Application) -> Bool {
        app.environment.name == PopulateWithRandomUserEvents.prepopulate
    }
    
    let logger = Logger(label: String(describing: PopulateWithRandomUserEvents.self))
    private func log(_ string: Logger.Message) {
        logger.info(string)
    }
    
    func prepare(on database: FluentKit.Database) async throws {

        log("Populating database with random events")

        let users = (0..<userCount).map { _ in UUID() }
        
        for _ in 0..<count {
            let event = UserEvent.random(for: users.randomElement()!, in: -timespan ... 0)
            let record = UserEventRecord(event)
            try await record.create(on: database)
        }

        log("Populated database with \(count) events for \(userCount) users, starting at \(Date().addingTimeInterval(-timespan))")
    }
    
    func revert(on database: FluentKit.Database) async throws {}
}

