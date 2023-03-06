@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func test_hello_returns_404() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // the server should respond with a 404
        // for any endpoint that isn't in
        // the controllers we add
        // so make sure that it does so for the original endpoint
        // that was there when the project was created
        try app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }
    
    func test_root_returns_404() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        // a request to root should return a 404
        try app.test(.GET, "", afterResponse: { res in
            XCTAssertEqual(res.status, .notFound)
        })
    }

}
