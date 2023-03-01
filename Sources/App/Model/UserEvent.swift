//
//  UserEvent.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Vapor

struct UserEvent: Content, Equatable {
    let timestamp: InternalDate
    
    init() {
        self.timestamp = InternalDate(Date())
    }
}
