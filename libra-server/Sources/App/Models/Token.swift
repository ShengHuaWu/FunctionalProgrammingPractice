import Vapor
import FluentPostgreSQL
import Authentication

final class Token: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case token
        case userID = "user_id"
    }
    
    var id: Int?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

// MARK: - PostgreSQLModel
extension Token: PostgreSQLModel {}

// MARK: - Content
extension Token: Content {}

// MARK: - Migration
extension Token: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id) // Set up a foreign key
        }
    }
}

// MARK: - Authentication Token
extension Token: Authentication.Token {
    typealias UserType = User
    
    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \.userID
    }
    
    static var tokenKey: WritableKeyPath<Token, String> {
        return \.token
    }
}

// MARK: - Helpers
extension Token {
    static func make(for user: User) throws -> Token {
        let random = try CryptoRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}
