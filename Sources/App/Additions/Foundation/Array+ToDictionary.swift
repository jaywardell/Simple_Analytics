//
//  Array+ToDictionary.swift
//  
//
//  Created by Joseph Wardell on 3/4/23.
//

import Foundation

extension Array {
    func toDictionary<Output>(_ transform: (Element)->Output)  -> [Element:Output] {
        var out = [Element:Output]()
        for element in self {
            out[element] = transform(element)
        }
        return out
    }
}
