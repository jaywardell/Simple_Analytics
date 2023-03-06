//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

@testable import App
import Vapor
import SimpleAnalyticsTypes


// these are really only used in the tests, but they work here
extension UserEvent {
    
    func toByteBuffer() -> ByteBuffer {
        try! JSONEncoder().encodeAsByteBuffer(self, allocator: .init())
    }
}
