import Vapor
import FluentPostgreSQL

final class Avatar: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userID = "user_id"
    }
    
    var id: Int?
    var name: String
    var userID: User.ID
    
    init(name: String, userID: User.ID) {
        self.name = name
        self.userID = userID
    }
}

// MARK: - PostgreSQLModel
extension Avatar: PostgreSQLModel {}

// MARK: - Content
extension Avatar: Content {}

// MARK: - Migration
extension Avatar: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id) // Set up a foreign key
        }
    }
}

// MARK: - Parameter
extension Avatar: Parameter {}

// MARK: - Helpers
extension Avatar {
    private var user: Parent<Avatar, User> {
        return parent(\.userID)
    }
}

extension HTTPResponse {
    init(avatar: Avatar) throws {
        try self.init(body: Current.resourcePersisting.fetch(avatar.name))
    }
}
