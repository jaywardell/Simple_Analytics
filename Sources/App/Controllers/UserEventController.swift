//
//  UserEventController.swift
//  
//
//  Created by Joseph Wardell on 2/28/23.
//

import Vapor

struct UserEventController {
    static var userevents: String { #function }
    static var verbose: String { #function }
    static var verboseTrue: String { "true" }
}

// MARK: - UserEventController: RouteCollection

extension UserEventController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let group = routes
            .grouped(.constant(Self.userevents))
            .grouped(HeaderCheckingMiddleware(key: Self.verbose, value: Self.verboseTrue))
        group.post(use: create)
    }
  
    func create(req: Request) async throws -> UserEvent {
        let event = try req.content.decode(UserEvent.self)
        let record = UserEventRecord(event)
        try await record.create(on: req.db)
        return record.userEvent
    }
}
