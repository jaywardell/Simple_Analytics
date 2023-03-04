//
//  UserController.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor
import FluentKit

extension PathComponent {
    static var users: PathComponent { PathComponent(stringLiteral: UserController.users) }
    static var count: PathComponent { PathComponent(stringLiteral: UserController.count) }
}

struct UserController {
    static var users: String { #function }
    static var count: String { #function }
    static var countPath: String { [users, count].joined(separator: "/") }
}

// MARK: - UserController: RouteCollection

extension UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let getroutes = routes
            .grouped(.constant(Self.users))
        getroutes.get(use: list)
        getroutes.get(.count, use: count)
    }
    
    private func query(from request: Request) throws -> QueryBuilder<UserEventRecord> {
        guard let query = UserEventRecord.query(from: request) else {
            throw Abort(.badRequest)
        }
        
        return query.unique()
    }
    
    private func list(request: Request) async throws -> [String] {
  
        try await query(from: request)
            .all(\.$userID)
            .map(\.uuidString)
    }
    
    private func count(request: Request) async throws -> Int {
        
        try await query(from: request)
            .count(\.$userID)
    }

}
