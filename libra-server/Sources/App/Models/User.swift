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
    
    var id: UUID?
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

// MARK: - PostgreSQLUUIDModel
// TODO: Remove UUID
extension User: PostgreSQLUUIDModel {}

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

// MARK: - Helpers
extension User {
    var records: Children<User, Record> {
        return children(\.creatorID)
    }
    
    func makePublic() -> Public {
        return Public(id: id, firstName: firstName, lastName: lastName, username: username, email: email)
    }
    
    static func makeQueryFuture(using ids: [User.ID], on conn: DatabaseConnectable) -> Future<[User]> {
        return User.query(on: conn).filter(.make(\User.id, .in, ids)).all()
    }
}
