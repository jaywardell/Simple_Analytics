//
//  HTTPHeaders+Convenience.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

import Vapor

extension HTTPHeaders {
    
    static var `true`: String { String(true) }
    static var `false`: String { String(false) }

    func adding<S: Sequence>(_ other: S) -> HTTPHeaders where S.Element == (String, String) {
        var out = self
        out.add(contentsOf: other)
        
        return out
    }
    
    func adding(_ other: (String, String)) -> HTTPHeaders  {
        return adding([other])
    }
}

