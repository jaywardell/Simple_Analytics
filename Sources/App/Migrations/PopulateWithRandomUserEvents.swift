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

        log("Populating database with \(Self.prepopulateCount) events starting at \(Date().addingTimeInterval(-Self.timeSpan))")

        for _ in 0..<Self.prepopulateCount {
            let event = UserEvent.random(in: -Self.timeSpan ... 0)
            let record = UserEventRecord(event)
            try await record.create(on: database)
        }
    }
    
    func revert(on database: FluentKit.Database) async throws {}
}
