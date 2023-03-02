//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/2/23.
//

import Vapor

/// A Middleware that checks the header for a given key-value pair.
/// If the key-value pair exists in the request header, then the original response is sent back.
/// If the key-value pair doesn't exist, then a default body is sent back instead (an empty body is the default)
struct HeaderCheckingMiddleware: AsyncMiddleware {
    
    let key: String
    let value: String
    let defaultBody: Response.Body
        
    init(key: String, value: String, defaultBody: Response.Body = .empty) {
        self.key = key
        self.value = value
        self.defaultBody = defaultBody
    }
    
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let response = try await next.respond(to: request)
        if let value = request.headers[key].first,
           value == self.value {
            return response
        }
        return Response(status: .ok, version: response.version, headersNoUpdate: response.headers, body: defaultBody)
    }
}

// MARK: -

/// a controller that offers one GET route
/// used for testing HeaderCheckingMiddleware
struct HeaderCheckingMiddlewareTestsController {
    static var standardResult: Int { 42 }
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
        group.get { _ in Self.standardResult }
    }
}

