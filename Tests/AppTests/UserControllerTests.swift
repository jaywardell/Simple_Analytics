//
//  UserControllerTests.swift
//  
//
//  Created by Joseph Wardell on 3/3/23.
//

@testable import App
import XCTVapor

final class UserControllerTests: XCTestCase {
    
    private var sut: Application!
    
    override func setUp() {
        sut = Application(.testing)
        try! configure(sut)
   }
    
    override func tearDown() {
        sut.shutdown()
    }
    
    // MARK: POST -  add UserEvent
    func test_get_list_returns_200() throws {
        try sut.test(.GET, UserController.users) { response in
            XCTAssertEqual(response.status, .ok)
        }
    }
}
