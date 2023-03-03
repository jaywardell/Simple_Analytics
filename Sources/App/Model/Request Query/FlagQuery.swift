//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

struct FlagQuery: Content {
    let flag: Bool?
        
    func filter(_ query: QueryBuilder<UserEventRecord>) -> QueryBuilder<UserEventRecord>? {
        guard let flag = flag else { return nil }
        return query.filter(\.$flag == flag)
    }
}
