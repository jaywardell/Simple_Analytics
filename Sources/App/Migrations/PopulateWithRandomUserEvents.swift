//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

import Vapor
import FluentKit

final class PopulateWithRandomUserEvents: AsyncMigration {
    
    private var createEventIDs = [UUID]()
    
    func prepare(on database: FluentKit.Database) async throws {
        
    }
    
    func revert(on database: FluentKit.Database) async throws {
        
    }
}
