//
//  UserEvent.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Vapor

struct UserEvent: Content, Equatable {
    let date: Date
    
    init() {
        self.date = Date(timeIntervalSinceReferenceDate: Date().timeIntervalSinceReferenceDate.rounded())
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let date = try? container.decode(Date.self, forKey: .date) {
            self.date = date
        }
        else if let dateDouble = try? container.decode(Double.self, forKey: .date) {
            self.date = Date(timeIntervalSinceReferenceDate: dateDouble)
        }
        else if let dateString = try? container.decode(String.self, forKey: .date) {
            let formatter = ISO8601DateFormatter()
            self.date = formatter.date(from: dateString)!
        }
        else {
            fatalError()
        }
    }
}
