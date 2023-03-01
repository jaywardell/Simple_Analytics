//
//  UserEvent.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Vapor

struct UserEvent: Content, Equatable {
    let id: UUID
    let timestamp: InternalDate
    
    init() {
        self.id = UUID()
        self.timestamp = InternalDate(Date())
    }
}
