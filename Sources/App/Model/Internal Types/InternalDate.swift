//
//  InternalDate.swift
//  
//
//  Created by Joseph Wardell on 3/1/23.
//

import Foundation

struct InternalDate: Codable, Equatable, Hashable {
    
    let value: Date
    
    init(_ date: Date) {
        self.value = Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate.rounded())
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        let dateDouble = try container.decode(Double.self)
        self.value = Date(timeIntervalSinceReferenceDate: dateDouble.rounded())
    }
    
    func encode(to encoder: Encoder) throws {
        try value.timeIntervalSinceReferenceDate.encode(to: encoder)
    }
}
