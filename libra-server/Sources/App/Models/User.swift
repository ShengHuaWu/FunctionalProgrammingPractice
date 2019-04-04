import Foundation
import Vapor
import FluentPostgreSQL

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

// MARK: - Public User
extension User {
    struct Public: Codable {
        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
            case username
            case email
        }
        
        let id: UUID?
        let firstName: String
        let lastName: String
        let username: String?
        let email: String
    }
    
    func toPublic() -> Public {
        return Public(id: id, firstName: firstName, lastName: lastName, username: username, email: email)
    }
}

// MARK: - Public User Content
extension User.Public: Content {}

// MARK: - Future Helpers
extension Future where T: User {
    func toPublic() -> Future<User.Public> {
        return map(to: User.Public.self) { $0.toPublic() }
    }
}

// MARK: - Helpers
extension User {
    var records: Children<User, Record> {
        return children(\.creatorID)
    }
    
    static func queryFuture(in ids: [User.ID], on conn: DatabaseConnectable) -> Future<[User]> {
        return User.query(on: conn).decode(User.self).filter(.make(\User.id, .in, ids)).all()
    }
}

// MARK: - User Array Helpers
extension Array where Element == User {
    func attachCompanionsFuture(for record: Record, on conn: DatabaseConnectable) throws -> Future<Record.Intact> {
        return map { companion in
            return record.companions.attach(companion, on: conn)
        }.flatMap(to: Record.Intact.self, on: conn) { _ in
            return try record.toIntactFuture(on: conn)
        }
    }
}
