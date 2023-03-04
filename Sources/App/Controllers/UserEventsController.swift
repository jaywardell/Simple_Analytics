//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

import Vapor

extension PathComponent {
    static var userevents: PathComponent { PathComponent(stringLiteral: UserEventsController.userevents) }
    static var list: PathComponent { PathComponent(stringLiteral: UserEventsController.list) }
}

struct UserEventsController {
    static var userevents: String { #function }
    static var list: String { #function }
    static var listPath: String { [userevents, list].joined(separator: "/") }
    
    // query keys

    static var startDate: String { #function }
    static var endDate: String { #function }
    static var timestamp: String { #function }
    static var action: String { #function }
    static var flag: String { #function }
    static var userID: String { #function }
}

// MARK: - UserEventController: RouteCollection

extension UserEventsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let getroutes = routes
            .grouped(.userevents)
        getroutes.get(.list, use: list)
    }
  
    func list(request: Request) async throws -> [UserEvent] {
        guard let query = UserEventRecord.query(from: request) else {  throw Abort(.badRequest) }
        
        return try await query
            .all()
            .map(\.userEvent)
    }
}

