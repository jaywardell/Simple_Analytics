//
//  Application+Convenience.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

@testable import App
import SimpleAnalyticsTypes
import Vapor


extension Application {
    
    func post(_ userEvents: [UserEvent]) throws {
        try userEvents.forEach {
            _ = try sendRequest(.POST, UserEventController.userevent, headers: .content_type_json, body: $0.toByteBuffer())
        }
    }

    func post(_ userEvent: UserEvent) throws {
        try post([userEvent])
    }

}
