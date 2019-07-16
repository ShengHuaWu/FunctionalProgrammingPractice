import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case password
        case email
    }
    
    var id: Int?
    var firstName: String
    var lastName: String
    var username: String
    var password: String
    var email: String
        
    init(firstName: String, lastName: String, username: String, password: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.email = email
    }
}

// MARK: - PostgreSQLModel
extension User: PostgreSQLModel {}

// MARK: - Content
extension User: Content {}

// MARK: - Parameter
extension User: Parameter {}

// MARK: - Migration
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username) // Add a unique index to username
        }
    }
}

// MARK: - Basic Authenticatable
extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \.username
    }
    
    static var passwordKey: WritableKeyPath<User, String> {
        return \.password
    }
}

// MARK: - Token Authenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

// MARK: - Helpers
extension User {
    var records: Children<User, Record> {
        return children(\.creatorID)
    }
    
    var friends: Siblings<User, User, FriendshipPivot> {
        return siblings(FriendshipPivot.leftIDKey, FriendshipPivot.rightIDKey)
    }
    
    var avatar: Children<User, Avatar> {
        return children(\.userID)
    }
    
    convenience init(userInfo: AuthenticationBody.UserInfo) {
        self.init(firstName: userInfo.firstName, lastName: userInfo.lastName, username: userInfo.username, password: userInfo.password, email: userInfo.email)
    }
    
    static func customTokenAuthMiddleware() -> CustomTokenAuthenticationMiddleware {
        return CustomTokenAuthenticationMiddleware()
    }
    
    func encryptPassword() throws -> User {
        password = try BCrypt.hash(password)
        return self
    }
    
    func update(with body: UpdateRequestBody) -> User {
        firstName = body.firstName
        lastName = body.lastName
        email = body.email
        
        return self
    }
}

// TODO: To be removed (Only used for attaching friends because they are the same type)
extension Siblings
    where Through: ModifiablePivot, Through.Left == Base, Through.Right == Related, Through.Left == Through.Right, Through.Database: QuerySupporting
{
    func attachSameType(_ model: Related, on conn: DatabaseConnectable) -> Future<Through> {
        return Future.flatMap(on: conn) {
            let pivot = try Through(self.base, model)
            return pivot.save(on: conn)
        }
    }
}
