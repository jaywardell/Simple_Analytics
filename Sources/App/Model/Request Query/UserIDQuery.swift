//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

struct UserIDQuery: Content {
    let userID: UUID
    
    func filter(_ query: QueryBuilder<UserEventRecord>) -> QueryBuilder<UserEventRecord> {
        query.filter(\.$userID == userID)
    }
}
