//
//  HTTPHeaders+Constants.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

import Vapor

extension HTTPHeaders {
    private static var content: String { #function }
    private static var type: String { #function }
    static var content_type: String { [content, type].joined(separator: "-") }
    
    private static var application: String { #function }
    private static var json: String { #function }
    static var application_json: String {
        [application, json].joined(separator: "/")
    }
    
    static var content_type_json: HTTPHeaders { HTTPHeaders(dictionaryLiteral: (Self.content_type, Self.application_json)) }
    
    static var verbose: String { #function }
    static var `true`: String { String(true) }
    static var `false`: String { String(false) }

    static var verbose_true: HTTPHeaders {
        HTTPHeaders(dictionaryLiteral: (verbose, Self.true))
    }
    
    static var verbose_false: HTTPHeaders {
        HTTPHeaders(dictionaryLiteral: (verbose, Self.false))
    }

    
    func adding<S: Sequence>(_ other: S) -> HTTPHeaders where S.Element == (String, String) {
        var out = self
        out.add(contentsOf: other)
        
        return out
    }
    
    func adding(_ other: HTTPHeaders) -> HTTPHeaders  {
        assert(other.count == 1)
        return adding([other.first!])
    }

}
