//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

struct ActionQuery: Content {
    let action: UserEvent.Action
    
    func filter(_ query: QueryBuilder<UserEventRecord>) -> QueryBuilder<UserEventRecord> {
        query.filter(\.$action == action)
    }
}
