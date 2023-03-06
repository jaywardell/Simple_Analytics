@testable import App
import XCTVapor

final class AppTests: SimpleVaporTests {
    
    
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
