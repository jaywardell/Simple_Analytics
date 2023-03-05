//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

struct DateRangeQuery: Content {
    var startDate: TimeInterval
    var endDate: TimeInterval
    var start: Double { startDate }
    var end: Double { endDate }
    
    func filter(_ query: QueryBuilder<UserEventRecord>) -> QueryBuilder<UserEventRecord> {
        query
            .filter(\.$timestamp  >= startDate)
            .filter(\.$timestamp  <= endDate)
    }
}

