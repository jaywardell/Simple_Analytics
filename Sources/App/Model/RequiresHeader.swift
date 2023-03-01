//
//  RequiresHeader.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Vapor

/// This is ONE WAY to insist that the heder include a certain key in order to provide a value back.
/// // TODO: I think there's probably a way to do this via middleware
struct RequiresHeader<Content: AsyncResponseEncodable> : AsyncResponseEncodable {
    
    let key: String
    let value: String
    let event: Content
    
    func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        if request.headers[key].first == value {
            return try await event.encodeResponse(for: request)
        }
        else {
            return try await "".encodeResponse(for: request)
        }
    }
}

// example use:
//
//    func create(req: Request) async throws -> RequiresHeader<UserEvent> {
//        let event = try req.content.decode(UserEvent.self)
//        return RequiresHeader(key: "verbose", value: "true",  event: event)
//    }

