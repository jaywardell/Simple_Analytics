//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

extension UserEventRecord {
    
    static func query(from request: Request) -> QueryBuilder<UserEventRecord>? {
        
        var query = UserEventRecord.query(on: request.db)
        
        var queryWasFound = false
        
        // TODO: this looks like a pattern that could be simplified somehow
        if let dateRange = try? request.query.decode(DateRangeQuery.self) {
            query = dateRange.filter(query)
            queryWasFound = true
        }
        if let actionQuery = try? request.query.decode(ActionQuery.self) {
            query = actionQuery.filter(query)
            queryWasFound = true
        }
        if let userIDQuery = try? request.query.decode(UserIDQuery.self) {
            query = userIDQuery.filter(query)
            queryWasFound = true
        }
        
        if let flagQuery = try? request.query.decode(FlagQuery.self),
           let q = flagQuery.filter(query) {
            query = q
            queryWasFound = true
        }

        if !queryWasFound && request.url.query?.isEmpty == false {
            return nil
        }

        return query
    }
    
}
