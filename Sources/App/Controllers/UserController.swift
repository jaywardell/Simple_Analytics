//
//  UserController.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

import Vapor

extension PathComponent {
    static var users: PathComponent { PathComponent(stringLiteral: UserEventController.list) }
}

struct UserController {
    static var users: String { #function }
}

// MARK: - UserController: RouteCollection

extension UserController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let getroutes = routes
            .grouped(.constant(Self.users))
        getroutes.get(use: list)
    }
    
    private func list(request: Request) async throws -> [String] {
        []
    }
}
