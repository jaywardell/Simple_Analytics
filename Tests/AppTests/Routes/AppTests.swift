@testable import App
import XCTVapor

final class AppTests: XCTVaporTests {
    
    override class func setUp() {
        XCTVapor.app = { Application(.testing) }
    }
    
    func makeSUT(configuration: ((Application) throws ->())? = nil) throws -> Application {
        try (configuration ?? configure)(app)
        return app
    }
    
    func test_hello_returns_404() throws {

        try makeSUT().test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }
    
    func test_root_returns_404() throws {

        try makeSUT().test(.GET, "", afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

}
