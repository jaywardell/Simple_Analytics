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
    private var createEventIDs = [UUID]()
    
    func prepare(on database: FluentKit.Database) async throws {
        
        let event = UserEvent(date: Date(), action: .allCases.randomElement()!, userID: UUID(), flag: .random())
        let record = UserEventRecord(event)
        try await record.create(on: database)
    }
    
    func revert(on database: FluentKit.Database) async throws {
        
    }
}

fileprivate extension UserEvent {
    
}
