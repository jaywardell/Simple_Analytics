//
//  UserEventRecord.swift
//  
//
//  Created by Joseph Wardell on 3/2/23.
//

import Vapor
import FluentKit

extension FieldKey {
    static var timestamp: FieldKey { #function }
    static var flag: FieldKey { #function }
    static var action: FieldKey { #function }
}


final class UserEventRecord: Model {
    
    static var usereventrecords: String { #function }
    static let schema = usereventrecords
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: .timestamp)
    var timestamp: InternalDate

    @Field(key: .flag)
    var flag: Bool
    
    @Enum(key: .action)
    var action: UserEvent.Action

    init() { }
    
    /// build a UserEventRecord from an existing UserEvent
    init(_ userEvent: UserEvent) {
        self.id = id
        
        // take the timestamp from the userEvent,
        // don't use a Fluent @Timestamp
        // because we want the time that the messge was sent
        // not the time that the record was created
        self.timestamp = userEvent.timestamp
        
        self.flag = userEvent.flag
        self.action = userEvent.action
    }
    
    /// return a UserEvent built from the properties of this record
    /// assuming that the record is stored in the daabase and has all valid properties
    var userEvent: UserEvent? {
        guard $id.exists else { return nil }
        
        // TODO: the userID should be stored in the database
        return UserEvent(action: action, userID: UUID(), flag: flag)
    }
}
