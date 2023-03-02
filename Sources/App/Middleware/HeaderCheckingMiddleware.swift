//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/2/23.
//

import Vapor

struct HeaderCheckingMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)
        return response
    }
}

// MARK: -

/// a controller that offers one GET route
/// used for testing HeaderCheckingMiddleware
struct HeaderCheckingMiddlewareTestsController {
    static var example: String { #function }
}

// MARK: - HeaderCheckingMiddlewareTestsController: RouteCollection

extension HeaderCheckingMiddlewareTestsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let group = routes.grouped(.constant(Self.example))
        group.get { _ in 42 }
    }
}

