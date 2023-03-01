//
//  UserEvent.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Vapor

struct UserEvent: Content, Equatable {
    let id: UUID
    
    let userID: UUID
    
    let flag: Bool
    let timestamp: InternalDate
    
    init(userID: UUID, flag: Bool = false) {
        self.id = UUID()
        
        self.userID = userID
        
        self.timestamp = InternalDate(Date())
        self.flag = flag
    }
}
