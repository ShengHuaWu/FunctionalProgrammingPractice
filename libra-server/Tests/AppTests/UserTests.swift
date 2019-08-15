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
    
    // TODO: Clean up code. Consider separating into different files
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
    
    func testThatGetOneUserSucceeds() throws {
        let (user, token, avatar) = try seedData()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getOneResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())", method: .GET, headers: headers, body: EmptyBody())
        let receivedUser = try getOneResponse.content.decode(User.Public.self).wait()
        
        XCTAssertEqual(receivedUser.id, user.id)
        XCTAssertEqual(receivedUser.firstName, user.firstName)
        XCTAssertEqual(receivedUser.lastName, user.lastName)
        XCTAssertEqual(receivedUser.username, user.username)
        XCTAssertEqual(receivedUser.email, user.email)
        XCTAssertNil(receivedUser.token)
        XCTAssertNotEqual(receivedUser.token, token.token)
        XCTAssertEqual(receivedUser.asset?.id, avatar.id)
    }
    
    func testThatGetOneUserThrowsUnauthorizedIfTokenIsWrong() throws {
        let (user, _, _) = try seedData()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let getOneResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneResponse.http.status, .unauthorized)
    }
    
    func testThatGetOneUserThrowsUnauthorizedIfUserCannotAccessResource() throws {
        let (_, token, _) = try seedData()
        
        let anotherUser = try User(firstName: "sheng", lastName: "wu", username: "sheng2", password: password, email: "sheng2@libra.co").encryptPassword().save(on: conn).wait()
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getOneResponse = try app.sendRequest(to: "api/v1/users/\(anotherUser.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneResponse.http.status, .unauthorized)
    }
    
    func testThatUpdateUserSucceeds() throws {
        let (user, token, avatar) = try seedData()
        
        let body = User.UpdateRequestBody(firstName: "shenghua", lastName: "wu", email: "shenghua@libra.co")
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let updateUserResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())", method: .PUT, headers: headers, body: body)
        let receivedUser = try updateUserResponse.content.decode(User.Public.self).wait()
        
        XCTAssertEqual(receivedUser.id, user.id)
        XCTAssertEqual(receivedUser.firstName, body.firstName)
        XCTAssertEqual(receivedUser.lastName, body.lastName)
        XCTAssertEqual(receivedUser.email, body.email)
        XCTAssertEqual(receivedUser.asset?.id, avatar.id)
        XCTAssertNil(receivedUser.token)
    }
    
    func testThatUpdateUserThrowsUnauthorizedIfTokenIsWrong() throws {
        let (user, _, _) = try seedData()
        
        let body = User.UpdateRequestBody(firstName: "shenghua", lastName: "wu", email: "shenghua@libra.co")
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let updateUserResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())", method: .PUT, headers: headers, body: body)
        
        XCTAssertEqual(updateUserResponse.http.status, .unauthorized)
    }
    
    func testThatUdpateUserThrowsUnauthorizedIfUserCannotAccessResource() throws {
        let (_, token, _) = try seedData()
        
        let anotherUser = try User(firstName: "sheng", lastName: "wu", username: "sheng2", password: password, email: "sheng2@libra.co").encryptPassword().save(on: conn).wait()
        let body = User.UpdateRequestBody(firstName: "shenghua", lastName: "wu", email: "shenghua@libra.co")
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let updateUserResponse = try app.sendRequest(to: "api/v1/users/\(anotherUser.requireID())", method: .PUT, headers: headers, body: body)
        
        XCTAssertEqual(updateUserResponse.http.status, .unauthorized)
    }
    
    func testThatSearchUsersSucceeds() throws {
        let (user, token, avatar) = try seedData()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let key = "shen"
        let searchUsersResponse = try app.sendRequest(to: "api/v1/users/search?q=\(key)", method: .GET, headers: headers, body: EmptyBody())
        let receivedUsers = try searchUsersResponse.content.decode([User.Public].self).wait()
        
        XCTAssertEqual(receivedUsers.count, 1)
        XCTAssertEqual(receivedUsers.first?.id, user.id)
        XCTAssertEqual(receivedUsers.first?.firstName, user.firstName)
        XCTAssertEqual(receivedUsers.first?.lastName, user.lastName)
        XCTAssertEqual(receivedUsers.first?.email, user.email)
        XCTAssertEqual(receivedUsers.first?.asset?.id, avatar.id)
        XCTAssertNil(receivedUsers.first?.token)
    }
    
    func testThatSearchUsersSucceedsWithEmptyResult() throws {
        let (_, token, _) = try seedData()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let key = "facebook"
        let searchUsersResponse = try app.sendRequest(to: "api/v1/users/search?q=\(key)", method: .GET, headers: headers, body: EmptyBody())
        let receivedUsers = try searchUsersResponse.content.decode([User.Public].self).wait()
        
        XCTAssertEqual(receivedUsers.count, 0)
    }
    
    func testThatSearchUserThrowsUnauthorizedIfTokenIsWrong() throws {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let key = "shen"
        let searchUsersResponse = try app.sendRequest(to: "api/v1/users/search?q=\(key)", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(searchUsersResponse.http.status, .unauthorized)
    }
    
    func testThatGetAllFriendsSucceeds() throws {
        let (user, token, _) = try seedData()
        let (person, _, avatar) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        XCTAssertEqual(addFriendResponse.http.status, .created)
        
        let getAllFriendsResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .GET, headers: headers, body: EmptyBody())
        let receivedFriends = try getAllFriendsResponse.content.decode([User.Public].self).wait()
        
        XCTAssertEqual(receivedFriends.count, 1)
        XCTAssertEqual(receivedFriends.first?.id, person.id)
        XCTAssertEqual(receivedFriends.first?.firstName, person.firstName)
        XCTAssertEqual(receivedFriends.first?.lastName, person.lastName)
        XCTAssertEqual(receivedFriends.first?.email, person.email)
        XCTAssertEqual(receivedFriends.first?.asset?.id, avatar.id)
        XCTAssertNil(receivedFriends.first?.token)
    }
    
    func testThatGetAllFriendsSucceedsWithEmptyResult() throws {
        let (user, token, _) = try seedData()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getAllFriendsResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .GET, headers: headers, body: EmptyBody())
        let receivedFriends = try getAllFriendsResponse.content.decode([User.Public].self).wait()
        
        XCTAssertEqual(receivedFriends.count, 0)
    }
    
    func testThatGetAllFriendsThrowsUnauthorizedIfTokenIsWrong() throws {
        let (user, token, _) = try seedData()
        let (person, _, _) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        XCTAssertEqual(addFriendResponse.http.status, .created)
        
        headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let getAllFriendsResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getAllFriendsResponse.http.status, .unauthorized)
    }
    
    func testThatGetAllFriendsThrowsUnauthorizedIfUserCannotAccessResource() throws {
        let (user, token, _) = try seedData()
        let (person, _, _) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        XCTAssertEqual(addFriendResponse.http.status, .created)

        let anotherUser = try User(firstName: "sheng", lastName: "wu", username: "sheng3", password: password, email: "sheng3@libra.co").encryptPassword().save(on: conn).wait()
        headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getAllFriendsResponse = try app.sendRequest(to: "api/v1/users/\(anotherUser.requireID())/friends", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getAllFriendsResponse.http.status, .unauthorized)
    }
    
    func testThatGetOneFriendSucceeds() throws {
        let (user, token, _) = try seedData()
        let (person, _, avatar) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        XCTAssertEqual(addFriendResponse.http.status, .created)
        
        let getOneFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends/\(person.requireID())", method: .GET, headers: headers, body: EmptyBody())
        let receivedFriend = try getOneFriendResponse.content.decode(User.Public.self).wait()
        
        XCTAssertEqual(receivedFriend.id, person.id)
        XCTAssertEqual(receivedFriend.firstName, person.firstName)
        XCTAssertEqual(receivedFriend.lastName, person.lastName)
        XCTAssertEqual(receivedFriend.email, person.email)
        XCTAssertEqual(receivedFriend.asset?.id, avatar.id)
        XCTAssertNil(receivedFriend.token)
    }
    
    func testThatGetOneFriendThrowsUnauthorizedIfTokenIsWrong() throws {
        let (user, token, _) = try seedData()
        let (person, _, _) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        XCTAssertEqual(addFriendResponse.http.status, .created)
        
        headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let getOneFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends/\(person.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneFriendResponse.http.status, .unauthorized)
    }
    
    func testThatGetOneFriendThrowsNotFoundIfThereIsNoFriendship() throws {
        let (user, token, _) = try seedData()
        let (person, _, _) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getOneFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends/\(person.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneFriendResponse.http.status, .notFound)
    }
    
    func testThatGetOneFriendThrowsUnauthorizedIfUserCannotAccessResource() throws {
        let (user, token, _) = try seedData()
        let (person, _, _) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        XCTAssertEqual(addFriendResponse.http.status, .created)
        
        let anotherUser = try User(firstName: "sheng", lastName: "wu", username: "sheng3", password: password, email: "sheng3@libra.co").encryptPassword().save(on: conn).wait()
        headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getOneFriendResponse = try app.sendRequest(to: "api/v1/users/\(anotherUser.requireID())/friends/\(person.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneFriendResponse.http.status, .unauthorized)
    }
    
    func testThatAddFriendSucceeds() throws {
        let (user, token, _) = try seedData()
        let (person, _, _) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        
        XCTAssertEqual(addFriendResponse.http.status, .created)
        
        let friends = try user.friends.query(on: conn).decode(User.self).all().wait()
        XCTAssertEqual(friends.count, 1)
        XCTAssertEqual(friends.first?.id, person.id)
        XCTAssertEqual(friends.first?.firstName, person.firstName)
        XCTAssertEqual(friends.first?.lastName, person.lastName)
        XCTAssertEqual(friends.first?.username, person.username)
        XCTAssertEqual(friends.first?.email, person.email)
    }
    
    func testThatAddFriendThrowsUnauthorizedIfTokenIsWrong() throws {
        let (user, _, _) = try seedData()
        let (person, _, _) = try seedData(username: "sheng2")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let body = try AddFriendBody(personID: person.requireID())
        let addFriendResponse = try app.sendRequest(to: "api/v1/users/\(user.requireID())/friends", method: .POST, headers: headers, body: body)
        
        XCTAssertEqual(addFriendResponse.http.status, .unauthorized)
    }
    
    // TODO: Unit tests
}

// MARK: - Private
private extension UserTests {
    // TODO: Clean up
    func seedData(username: String = "sheng1", isTokenRevoked: Bool = false) throws -> (User, Token, Avatar) {
        let user = try User(firstName: "sheng", lastName: "wu", username: username, password: password, email: "\(username)@libra.co").encryptPassword().save(on: conn).wait()
        let token = try Token(token: "4rfv5tgb6yhn==", isRevoked: isTokenRevoked, osName: "mac os", timeZone: "CEST", userID: user.requireID()).save(on: conn).wait()
        let avatar = try Avatar(name: "XYZ", userID: user.requireID()).save(on: conn).wait()
        
        return (user, token, avatar)
    }
}
