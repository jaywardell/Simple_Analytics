//
//  UserEventRecord.swift
//  
//
//  Created by Joseph Wardell on 3/2/23.
//

import Vapor
import FluentKit
import SimpleAnalyticsTypes

extension FieldKey {
    static var timestamp: FieldKey { #function }
    static var flag: FieldKey { #function }
    static var action: FieldKey { #function }
    static var userID: FieldKey { #function }
}


final class UserEventRecord: Model {
    
    static var usereventrecords: String { #function }
    static let schema = usereventrecords
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: .userID)
    var userID: UUID
    
    @Field(key: .timestamp)
    var timestamp: TimeInterval

    @Field(key: .flag)
    var flag: Bool
    
    @Enum(key: .action)
    var action: UserEvent.Action

    init() { }
    
    /// build a UserEventRecord from an existing UserEvent
    init(id: UUID? = nil, _ userEvent: UserEvent) {
        self.id = id
        
        // take the timestamp from the userEvent,
        // don't use a Fluent @Timestamp
        // because we want the time that the event happened
        // not the time that the record was created
        self.timestamp = userEvent.timestamp
        
        self.userID = userEvent.userID
        
        self.flag = userEvent.flag
        self.action = userEvent.action
    }
    
    /// return a UserEvent built from the properties of this record
    /// assuming that the record is stored in the daabase and has all valid properties
    var userEvent: UserEvent {
        return UserEvent(
            date: Date(timeIntervalSinceReferenceDate: timestamp),
            action: action,
            userID: userID,
            flag: flag)
    }
}
