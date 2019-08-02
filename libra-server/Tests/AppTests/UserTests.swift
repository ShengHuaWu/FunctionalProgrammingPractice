@testable import App
import Vapor
import FluentPostgreSQL
import XCTest

final class UserTests: XCTestCase {
    var app: Application!
    var conn: PostgreSQLConnection!
    var password = "12345678"

    override func setUp() {
        super.setUp()
        
        try! Application.reset() // Reset database
        
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        super.tearDown()
        
        conn.close()
    }
    
    // TODO: Clean up code
    // Remove `wait()` from `sendRequest`
    func testThatSignupSucceeds() throws {
        let userInfo = AuthenticationBody.UserInfo(username: "sheng1", password: "12345678", firstName: "sheng", lastName: "wu", email: "sheng1@libra.co")
        let body = AuthenticationBody(userInfo: userInfo, osName: "mac os", timeZone: "CEST")
        let signupResponse = try app.sendRequest(to: "api/v1/users/signup", method: .POST, headers: ["Content-Type": "application/json"], body: body)
        let receivedUser = try signupResponse.content.decode(User.Public.self).wait()
        
        XCTAssertNotNil(receivedUser.id)
        XCTAssertNotNil(receivedUser.token)
        XCTAssertEqual(receivedUser.username, "sheng1")
        XCTAssertEqual(receivedUser.firstName, "sheng")
        XCTAssertEqual(receivedUser.lastName, "wu")
        XCTAssertEqual(receivedUser.email, "sheng1@libra.co")
    }
    
    func testThatSignupThrowsBadRequestIfThereIsNoUserInfo() throws {
        let body = AuthenticationBody(userInfo: nil, osName: "mac os", timeZone: "CEST")
        let signupResponse = try app.sendRequest(to: "api/v1/users/signup", method: .POST, headers: ["Content-Type": "application/json"], body: body)
        
        XCTAssertEqual(signupResponse.http.status, .badRequest)
    }
    
    func testThatLoginSucceedsWithAnExistingToken() throws {
        let (user, token, avatar) = try seedData()
        
        let body = AuthenticationBody(userInfo: nil, osName: token.osName, timeZone: token.timeZone)
        let credentials = BasicAuthorization(username: user.username, password: password)
        var headers = HTTPHeaders()
        headers.basicAuthorization = credentials
        let loginResponse = try app.sendRequest(to: "api/v1/users/login", method: .POST, headers: headers, body: body)
        let receivedUser = try loginResponse.content.decode(User.Public.self).wait()
        
        XCTAssertEqual(receivedUser.id, user.id)
        XCTAssertEqual(receivedUser.firstName, user.firstName)
        XCTAssertEqual(receivedUser.lastName, user.lastName)
        XCTAssertEqual(receivedUser.username, user.username)
        XCTAssertEqual(receivedUser.email, user.email)
        XCTAssertEqual(receivedUser.token, token.token)
        XCTAssertEqual(receivedUser.asset?.id, avatar.id)
    }
    
    func testThatLoginSucceedsWithANewToken() throws {
        let (user, token, avatar) = try seedData(isTokenRevoked: true)
        
        let body = AuthenticationBody(userInfo: nil, osName: token.osName, timeZone: token.timeZone)
        let credentials = BasicAuthorization(username: user.username, password: password)
        var headers = HTTPHeaders()
        headers.basicAuthorization = credentials
        let loginResponse = try app.sendRequest(to: "api/v1/users/login", method: .POST, headers: headers, body: body)
        let receivedUser = try loginResponse.content.decode(User.Public.self).wait()
        
        XCTAssertEqual(receivedUser.id, user.id)
        XCTAssertEqual(receivedUser.firstName, user.firstName)
        XCTAssertEqual(receivedUser.lastName, user.lastName)
        XCTAssertEqual(receivedUser.username, user.username)
        XCTAssertEqual(receivedUser.email, user.email)
        XCTAssertTrue(!receivedUser.token!.isEmpty)
        XCTAssertNotEqual(receivedUser.token, token.token)
        XCTAssertEqual(receivedUser.asset?.id, avatar.id)
    }
    
    func testThatLoginThrowsUnauthorizedIfUserDoesNotExist() throws {
        let body = AuthenticationBody(userInfo: nil, osName: "mac os", timeZone: "CEST")
        let credentials = BasicAuthorization(username: "sheng1", password: "12345678")
        var headers = HTTPHeaders()
        headers.basicAuthorization = credentials
        let loginResponse = try app.sendRequest(to: "api/v1/users/login", method: .POST, headers: headers, body: body)
        
        XCTAssertEqual(loginResponse.http.status, .unauthorized)
    }
    
    func testThatLoginThrowsUnauthorizedIfUsernameIsWrong() throws {
        let (_, token, _) = try seedData()

        let body = AuthenticationBody(userInfo: nil, osName: token.token, timeZone: token.timeZone)
        let credentials = BasicAuthorization(username: "sheng2", password: password)
        var headers = HTTPHeaders()
        headers.basicAuthorization = credentials
        let loginResponse = try app.sendRequest(to: "api/v1/users/login", method: .POST, headers: headers, body: body)
        
        XCTAssertEqual(loginResponse.http.status, .unauthorized)
    }
    
    func testThatLoginThrowsUnauthorizedIfPasswordIsWrong() throws {
        let (user, token, _) = try seedData()

        let body = AuthenticationBody(userInfo: nil, osName: token.osName, timeZone: token.timeZone)
        let credentials = BasicAuthorization(username: user.username, password: "87654321")
        var headers = HTTPHeaders()
        headers.basicAuthorization = credentials
        let loginResponse = try app.sendRequest(to: "api/v1/users/login", method: .POST, headers: headers, body: body)
        
        XCTAssertEqual(loginResponse.http.status, .unauthorized)
    }
    
    func testThatLogoutSucceeds() throws {
        let (user, token, _) = try seedData()
        
        let body = AuthenticationBody(userInfo: nil, osName: token.osName, timeZone: token.timeZone)
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let logoutResponse = try app.sendRequest(to: "api/v1/users/logout", method: .DELETE, headers: headers, body: body)
        
        XCTAssertEqual(logoutResponse.http.status, .noContent)
        
        let revokedToken = try user.authTokens.query(on: conn).filter(\.isRevoked == true).first().wait()
        XCTAssertTrue(revokedToken!.isRevoked)
    }
    
    func testThatLogoutThrowsUnauthorizedIfTokenIsWrong() throws {
        let (_, token, _) = try seedData()

        let body = AuthenticationBody(userInfo: nil, osName: token.osName, timeZone: token.timeZone)
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "ABC")
        let logoutResponse = try app.sendRequest(to: "api/v1/users/logout", method: .DELETE, headers: headers, body: body)
        
        XCTAssertEqual(logoutResponse.http.status, .unauthorized)
    }
    
    func testThatLogoutThrowsNotFoundIfOSNameIsWrong() throws {
        let (_, token, _) = try seedData()
        
        let body = AuthenticationBody(userInfo: nil, osName: "ios", timeZone: token.timeZone)
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let logoutResponse = try app.sendRequest(to: "api/v1/users/logout", method: .DELETE, headers: headers, body: body)
        
        XCTAssertEqual(logoutResponse.http.status, .notFound)
    }
    
    func testThatLogoutThrowsNotFoundIfTimeZoneIsWrong() throws {
        let (_, token, _) = try seedData()
        
        let body = AuthenticationBody(userInfo: nil, osName: token.osName, timeZone: "CET")
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let logoutResponse = try app.sendRequest(to: "api/v1/users/logout", method: .DELETE, headers: headers, body: body)
        
        XCTAssertEqual(logoutResponse.http.status, .notFound)
    }
    
    // TODO: Unit tests
}

// MARK: - Private
private extension UserTests {
    func seedData(isTokenRevoked: Bool = false) throws -> (User, Token, Avatar) {
        let user = try User(firstName: "sheng", lastName: "wu", username: "sheng1", password: password, email: "sheng1@libra.co").encryptPassword().save(on: conn).wait()
        let token = try Token(token: "4rfv5tgb6yhn==", isRevoked: isTokenRevoked, osName: "mac os", timeZone: "CEST", userID: user.requireID()).save(on: conn).wait()
        let avatar = try Avatar(name: "XYZ", userID: user.requireID()).save(on: conn).wait()
        
        return (user, token, avatar)
    }
}
