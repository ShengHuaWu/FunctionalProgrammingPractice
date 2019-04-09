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
    
    func encryptPassword() throws -> User {
        password = try BCrypt.hash(password)
        return self
    }
    
    func makePublic(with token: Token? = nil) -> Public {
        return Public(id: id, firstName: firstName, lastName: lastName, username: username, email: email, token: token?.token)
    }
    
    func update(with body: UpdateRequestBody) -> User {
        firstName = body.firstName
        lastName = body.lastName
        email = body.email
        
        return self
    }
    
    // TODO: Find token before creating a new one (`authTokens`)
    func makeToken() throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: requireID())
    }
    
    static func makeQueryFuture(using ids: [User.ID], on conn: DatabaseConnectable) -> Future<[User]> {
        return User.query(on: conn).filter(.make(\User.id, .in, ids)).all()
    }
}
