//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

import Vapor

enum RequiresQueryMiddleware: AsyncMiddleware {
    
    case middleware
    
    func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
        
        guard request.url.query?.isEmpty == false else {
            throw Abort(.badRequest )
        }
        
        let response = try await next.respond(to: request)
        return response
    }
}

// MARK: -

/// a controller that offers one GET route
/// used for testing RequiresQueryMiddleware
struct RequiresQueryMiddlewareTestsController {
    static var standardResult: Int { 42 }
    static var middleware_example: String { #function + String(describing: Self.self) }
//    static let middleware =
//    RequiresQueryMiddleware()
}

// MARK: - RequiresQueryMiddlewareTestsController: RouteCollection

extension RequiresQueryMiddlewareTestsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let group = routes
            .grouped(.constant(Self.middleware_example))
            .grouped(RequiresQueryMiddleware.middleware)
        group.get { _ in Self.standardResult }
    }
}

