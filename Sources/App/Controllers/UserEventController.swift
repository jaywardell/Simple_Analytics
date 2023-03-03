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
    
    // query keys
    static var verbose: String { #function }
    static var verboseTrue: String { String(true) }

    static var startDate: String { #function }
    static var endDate: String { #function }
    static var action: String { #function }
    static var flag: String { #function }
    static var userID: String { #function }
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
        var query = UserEventRecord.query(on: request.db)
        
        var queryWasFound = false
        
        // TODO: this looks like a pattern that could be simplified somehow
        if let dateRange = try? request.query.decode(DateRangeQuery.self) {
            query = dateRange.filter(query)
            queryWasFound = true
        }
        if let actionQuery = try? request.query.decode(ActionQuery.self) {
            query = actionQuery.filter(query)
            queryWasFound = true
        }
        if let userIDQuery = try? request.query.decode(UserIDQuery.self) {
            query = userIDQuery.filter(query)
            queryWasFound = true
        }
        
        if let flagQuery = try? request.query.decode(FlagQuery.self),
           let q = flagQuery.filter(query) {
            query = q
            queryWasFound = true
        }

        if !queryWasFound && request.url.query?.isEmpty == false {
            throw Abort(.badRequest)
        }
                
        return try await query
            .all()
            .map(\.userEvent)
    }
}




