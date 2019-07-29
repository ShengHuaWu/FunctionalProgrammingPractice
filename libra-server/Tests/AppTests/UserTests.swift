@testable import App
import Vapor
import FluentPostgreSQL
import XCTest

final class UserTests: XCTestCase {
    var app: Application!
    var conn: PostgreSQLConnection!

    override func setUp() {
        super.setUp()
        
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        super.tearDown()
        
        conn.close()
    }
    
    func testThatSignUpUserSucceeds() throws {
        let userInfo = AuthenticationBody.UserInfo(username: "sheng1", password: "12345678", firstName: "sheng", lastName: "wu", email: "sheng1@libra.co")
        let body = AuthenticationBody(userInfo: userInfo, osName: "mac os", timeZone: "CEST")
        let signUpResponse = try app.sendRequest(to: "api/v1/users", method: .POST, body: body, isLoggedInRequest: false)
        let receivedUser = try signUpResponse.content.decode(User.Public.self).wait()
        
        XCTAssertNotNil(receivedUser.id)
        XCTAssertNotNil(receivedUser.token)
        XCTAssertEqual(receivedUser.username, "sheng1")
        XCTAssertEqual(receivedUser.firstName, "sheng")
        XCTAssertEqual(receivedUser.lastName, "wu")
        XCTAssertEqual(receivedUser.email, "sheng1@libra.co")
    }
}
