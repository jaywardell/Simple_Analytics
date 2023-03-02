//
//  CreateUserEventRecords.swift
//  
//
//  Created by Joseph Wardell on 3/2/23.
//

import Vapor
import FluentKit

struct CreateUserEventRecords: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(UserEventRecord.usereventrecords)
            .id()
            .field(.timestamp, .double)
            .field(.userID, .uuid)
            .field(.flag, .bool)
            .field(.action, .string)
            .create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        
    }

}
