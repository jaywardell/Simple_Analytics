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
    
    public class var environment: Environment { .testing }

    override class func setUp() {
        XCTVapor.app = { Application(environment) }
    }
    
    func makeSUT() throws -> Application {
        try configure(app)
        return app
    }
}
