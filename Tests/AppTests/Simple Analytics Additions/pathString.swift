//
//  pathString.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

@testable import App
import Foundation

func pathString(_ path: String, adding queries: [(String, String)]) -> String {
    guard queries.count > 0 else { return path }
    return path + "?" + queries.map { "\($0)=\($1)" }.joined(separator: "&")
}

func endpoint(_ path: String,
    startDate: Date? = nil,
              endDate: Date? = nil,
              userID: UUID? = nil,
              action: UserEvent.Action? = nil,
              flag: Bool? = nil) -> String {
    var queries = [(String, String)]()
    if let startDate {
        queries.append((UserEventController.startDate, String(startDate.timeIntervalSinceReferenceDate)))
    }
    if let endDate {
        queries.append((UserEventController.endDate, String(endDate.timeIntervalSinceReferenceDate)))
    }
    if let userID {
        queries.append((UserEventController.userID, userID.uuidString))
    }
    if let action {
        queries.append((UserEventController.action, action.rawValue))
    }
    if let flag {
        queries.append((UserEventController.flag, String(flag)))
    }
    
    // shuffle the queries to ensure that the server is robust about how it handles queries in any order
    return pathString(path, adding: queries.shuffled())
}
