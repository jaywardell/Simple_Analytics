//
//  UserEventController.swift
//  
//
//  Created by Joseph Wardell on 2/28/23.
//

import Vapor

extension PathComponent {
    static var userevent: PathComponent { PathComponent(stringLiteral: UserEventController.userevent) }
}

struct UserEventController {
    static var userevent: String { #function }
}

// MARK: - UserEventController: RouteCollection

extension UserEventController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let postroutes = routes
            .grouped(.userevent)
            .grouped(HeaderCheckingMiddleware(key: HTTPHeaders.verbose, value: HTTPHeaders.true))
        postroutes.post(use: add)
    }
  
    func add(request: Request) async throws -> UserEvent {
        let event = try request.content.decode(UserEvent.self)
        let record = UserEventRecord(event)
        try await record.create(on: request.db)
        return record.userEvent
    }
}




