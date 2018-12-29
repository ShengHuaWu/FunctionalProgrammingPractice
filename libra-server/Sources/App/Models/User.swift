import Foundation
import Vapor
import FluentPostgreSQL

final class User: Codable {
    var id: UUID?
    var firstName: String
    var lastName: String
    var username: String
    var password: String
    
    init(firstName: String, lastName: String, username: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
    }
}

// MARK: - PostgreSQLUUIDModel
extension User: PostgreSQLUUIDModel {}

// MARK: - Content
extension User: Content {}

// MARK: - Migration
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username) // Add a unique index to username
        }
    }
}
