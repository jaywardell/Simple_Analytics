//
//  Environment.Key.swift
//  
//
//  Created by Joseph Wardell on 3/8/23.
//

import Vapor

protocol EnvironmentKey {
    init?(_ string: String)
}
extension EnvironmentKey {
    init?(_ string: String?) {
        guard let string else { return nil }
        self.init(string)
    }
}

extension Int: EnvironmentKey {}
extension Double: EnvironmentKey {}
extension String: EnvironmentKey {}
extension Bool: EnvironmentKey {}

// MARK: -

extension Environment {
    
    @propertyWrapper
    struct Key<Value: EnvironmentKey> {
        let key: String
        let defaultValue: Value
        
        init(_ key: String, _ defaultValue: Value) {
            self.key = key
            self.defaultValue = defaultValue
        }
        
        var wrappedValue: Value {
            get {
                return Value(Environment.get(key)) ?? defaultValue
            }
        }
    }
}
