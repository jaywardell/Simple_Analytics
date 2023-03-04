//
//  HTTPHeaders+Constants.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

import Vapor

// MARK: - application/json
extension HTTPHeaders {
    private static var content: String { #function }
    private static var type: String { #function }
    static var content_type: String { [content, type].joined(separator: "-") }
    
    private static var application: String { #function }
    private static var json: String { #function }
    static var application_json: String {
        [application, json].joined(separator: "/")
    }

    func content_type_json() -> HTTPHeaders {
        adding((Self.content_type, Self.application_json))
    }

    static var content_type_json: HTTPHeaders {
        HTTPHeaders().content_type_json()
    }
}

// MARK: - verbose
extension HTTPHeaders {
    static var verbose: String { #function }
    
    static var verbose_false: HTTPHeaders {
        HTTPHeaders(dictionaryLiteral: (verbose, Self.false))
    }

    func verbose(_ value: Bool = true) -> HTTPHeaders {
        adding((Self.verbose, value ? Self.true : Self.false))
    }
    
}
