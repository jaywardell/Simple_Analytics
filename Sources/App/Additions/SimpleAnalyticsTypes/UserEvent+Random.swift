//
//  UserEvent+Random.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

import Foundation
import SimpleAnalyticsTypes

extension UserEvent {
    
    /// returns a UserEvent with all random properties except for a date at the date passed in.
    static func random(for userID: UUID? = nil, at date: Date) -> UserEvent {
        UserEvent(date: date, action: .allCases.randomElement()!, userID: userID ?? .generateRandom(), flag: .random())
    }
    
    static func random(for userID: UUID? = nil, in dateRange: ClosedRange<TimeInterval>) -> UserEvent {
        random(for: userID, at: Date().addingTimeInterval(.random(in: dateRange)))
    }
}
