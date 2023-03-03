//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

struct DateRangeQuery: Content {
    var startDate: InternalDate
    var endDate: InternalDate
    var start: Double { startDate.value.timeIntervalSinceReferenceDate }
    var end: Double { endDate.value.timeIntervalSinceReferenceDate }
    
    func filter(_ query: QueryBuilder<UserEventRecord>) -> QueryBuilder<UserEventRecord> {
        query
            .filter(\.$timestamp  >= startDate.value.timeIntervalSinceReferenceDate)
            .filter(\.$timestamp  <= endDate.value.timeIntervalSinceReferenceDate)
    }
}

