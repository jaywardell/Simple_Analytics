//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

import Vapor
import FluentKit

final class PopulateWithRandomUserEvents: AsyncMigration {
    
    private(set) static var hasRun = false
    
    static var prepopulate: String { "prepopulate_with_random" }
    private var createEventIDs = [UUID]()
    
    func prepare(on database: FluentKit.Database) async throws {
        Self.hasRun = true
    }
    
    func revert(on database: FluentKit.Database) async throws {
        
    }
}
