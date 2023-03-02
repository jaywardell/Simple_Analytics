//
//  UserEventController.swift
//  
//
//  Created by Joseph Wardell on 2/28/23.
//

import Vapor

extension PathComponent {
    static var list: PathComponent { PathComponent(stringLiteral: UserEventController.list) }
}

struct UserEventController {
    static var userevents: String { #function }
    static var list: String { #function }
    static var listPath: String { [userevents, list].joined(separator: "/") }
    static var verbose: String { #function }
    static var verboseTrue: String { "true" }
}

// MARK: - UserEventController: RouteCollection

extension UserEventController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let getroutes = routes
            .grouped(.constant(Self.userevents))
        getroutes.get(.list, use: list)

        let postroutes = getroutes
            .grouped(HeaderCheckingMiddleware(key: Self.verbose, value: Self.verboseTrue))
        postroutes.post(use: add)
    }
  
    func add(request: Request) async throws -> UserEvent {
        let event = try request.content.decode(UserEvent.self)
        let record = UserEventRecord(event)
        try await record.create(on: request.db)
        return record.userEvent
    }
    
    func list(request: Request) async throws -> [UserEvent] {
        try await UserEventRecord.query(on: request.db)
            .all()
            .map(\.userEvent)
    }
}
