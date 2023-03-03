//
//  UserEventController.swift
//  
//
//  Created by Joseph Wardell on 2/28/23.
//

import Vapor
import FluentKit

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
        
        if let dateRange = try? request.query.decode(DateRangeQuery.self) {
            query = query
                .filter(\.$timestamp  >= dateRange.startDate.value.timeIntervalSinceReferenceDate)
                .filter(\.$timestamp  <= dateRange.endDate.value.timeIntervalSinceReferenceDate)
        }
        else if request.url.query?.isEmpty == false {
            throw Abort(.badRequest)
        }
        
        return try await query
            .all()
            .map(\.userEvent)
    }
}

struct DateRangeQuery: Content {
    var startDate: InternalDate
    var endDate: InternalDate
    var start: Double { startDate.value.timeIntervalSinceReferenceDate }
    var end: Double { endDate.value.timeIntervalSinceReferenceDate }
}
