//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/2/23.
//

import Vapor

struct HeaderCheckingMiddleware: AsyncMiddleware {
    
    let key: String
    let value: String
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)
        if let value = request.headers[key].first,
           value == self.value {
            return response
        }
        return Response(status: .ok, version: response.version, headersNoUpdate: response.headers, body: "")
    }
}

// MARK: -

/// a controller that offers one GET route
/// used for testing HeaderCheckingMiddleware
struct HeaderCheckingMiddlewareTestsController {
    static var middleware_example: String { #function }
    static var example_header_key: String { #function }
    static var example_header_value: String { #function }
    static let middleware =
        HeaderCheckingMiddleware(key: Self.example_header_key, value: Self.example_header_value)
}

// MARK: - HeaderCheckingMiddlewareTestsController: RouteCollection

extension HeaderCheckingMiddlewareTestsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        let group = routes
            .grouped(.constant(Self.middleware_example))
            .grouped(Self.middleware)
        group.get { _ in 42 }
    }
}

