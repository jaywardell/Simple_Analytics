//
//  File.swift
//  
//
//  Created by Joseph Wardell on 3/6/23.
//

import App
import XCTVapor

/// A XCTVaporTests instance that does the simplest thing possible to set up its app
/// and offers a makeSUT() method that configures the app
class SimpleVaporTests: XCTVaporTests {
    
    override class func setUp() {
        XCTVapor.app = { Application(.testing) }
    }
    
    func makeSUT(configuration: ((Application) throws ->())? = nil) throws -> Application {
        try (configuration ?? configure)(app)
        return app
    }
}
