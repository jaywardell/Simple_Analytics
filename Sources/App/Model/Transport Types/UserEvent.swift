//
//  UserEvent.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Vapor

struct UserEvent: Content, Equatable, Hashable {
    
    let userID: UUID
    
    let flag: Bool
    let timestamp: InternalDate
    
    enum Action: String, Codable, CaseIterable {
        case start, pause, stop
    }
    let action: Action
        
    init(date: Date, action: Action, userID: UUID, flag: Bool = false) {
        self.userID = userID
        
        self.timestamp = InternalDate(date)
        self.flag = flag
        self.action = action
    }

    init(action: Action, userID: UUID, flag: Bool = false) {
        self.init(date: Date(), action: action, userID: userID, flag: flag)
    }
}
