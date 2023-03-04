//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

@testable import App
import Vapor


// these are really only used in the tests, but they work here
extension UserEvent {
    
    func toByteBuffer() -> ByteBuffer {
        try! JSONEncoder().encodeAsByteBuffer(self, allocator: .init())
    }

    /// returns a UserEvent with all random properties except for a date at the date passed in.
    static func random(for userID: UUID? = nil, at date: Date) -> UserEvent {
        UserEvent(date: date, action: .allCases.randomElement()!, userID: userID ?? .generateRandom(), flag: .random())
    }
}
