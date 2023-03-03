//
//  UserController.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor

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
    
    private func list(request: Request) async throws -> [String] {
        try await UserEventRecord.query(on: request.db)
            .unique()
            .all(\.$userID)
            .map(String.init)
    }
    
    private func count(request: Request) async throws -> Int {
        try await UserEventRecord.query(on: request.db)
            .unique()
            .all(\.$userID)
            .count
    }

}
