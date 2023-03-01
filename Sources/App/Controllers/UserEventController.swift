//
//  UserEventController.swift
//  
//
//  Created by Joseph Wardell on 2/28/23.
//

import Vapor

struct UserEventController {
    static var userevents: String { #function }
}

// MARK: - UserEventController: RouteCollection

extension UserEventController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let group = routes.grouped(.constant(Self.userevents))
        group.post(use: create)
    }
    
    func create(req: Request) async throws -> String {
        ""
    }
}