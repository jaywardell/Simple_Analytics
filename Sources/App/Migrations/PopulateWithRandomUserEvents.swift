//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

import Vapor
import FluentKit
import SimpleAnalyticsTypes

final class PopulateWithRandomUserEvents: AsyncMigration {
        
    @Environment.Key("count", 10_000) var count: Int
    @Environment.Key("users", 10) var users: Int
    @Environment.Key("timespan", 24*2600*365*3) var timespan: TimeInterval

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

        log("Populating database with \(count) events for \(users) users, starting at \(Date().addingTimeInterval(-timespan))")

        for _ in 0..<Self.prepopulateCount {
            let event = UserEvent.random(in: -Self.timeSpan ... 0)
            let record = UserEventRecord(event)
            try await record.create(on: database)
        }
    }
    
    func revert(on database: FluentKit.Database) async throws {}
}

