//
//  UserEvent.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Vapor

struct UserEvent: Content, Equatable {
    let id: UUID
    
    let flag: Bool
    let timestamp: InternalDate
    
    init(flag: Bool = false) {
        self.id = UUID()
        
        self.timestamp = InternalDate(Date())
        self.flag = flag
    }
}
