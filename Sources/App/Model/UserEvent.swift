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
    
    enum Action: String, Codable {
        case start, pause, stop
    }
    let action: Action
    
    init(action: Action, userID: UUID, flag: Bool = false) {
        self.id = UUID()
        
        self.userID = userID
        
        self.timestamp = InternalDate(Date())
        self.flag = flag
        self.action = action
    }
}
