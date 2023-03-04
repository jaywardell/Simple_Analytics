//
//  UserController.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

extension PathComponent {
    static var users: PathComponent { PathComponent(stringLiteral: UsersController.users) }
    static var count: PathComponent { PathComponent(stringLiteral: UsersController.count) }
    static var summary: PathComponent { PathComponent(stringLiteral: UsersController.summary) }
}

struct UsersController {
    static var users: String { #function }
    static var count: String { #function }
    static var summary: String { #function }
    static var countPath: String { [users, count].joined(separator: "/") }
    static var summaryPath: String { [users, summary].joined(separator: "/") }
}

// MARK: - UserController: RouteCollection

extension UsersController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let getroutes = routes
            .grouped(.constant(Self.users))
        
        getroutes.get(use: list)
        getroutes.get(.count, use: count)
        getroutes.get(.summary, use: summarize)
    }
    
    private func query(from request: Request) throws -> QueryBuilder<UserEventRecord> {
        guard let query = UserEventRecord.query(from: request) else {
            throw Abort(.badRequest)
        }
        
        return query
    }
    
    private func list(request: Request) async throws -> [String] {
  
        try await query(from: request)
            .unique()
            .all(\.$userID)
            .map(\.uuidString)
    }
    
    private func count(request: Request) async throws -> Int {
        
        try await query(from: request)
            .unique()
            .count(\.$userID)
    }

    private func summarize(request: Request) async throws -> [String:Int] {
        let query = try query(from: request)
        
        let events = try await query
            .all()
        
        let users = try await query
            .unique()
            .all(\.$userID)
            .map(\.uuidString)
        
        return users.toDictionary { user in
            events
                .filter { $0.userID.uuidString == user }
                .count
        }
    }
}

