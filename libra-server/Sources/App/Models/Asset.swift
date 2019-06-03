import Vapor
import FluentPostgreSQL

final class Asset: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case recordID = "record_id"
    }
    
    var id: Int?
    var name: String
    var recordID: Record.ID
    
    init(name: String, recordID: Record.ID) {
        self.name = name
        self.recordID = recordID
    }
}

// MARK: - PostgreSQLModel
extension Asset: PostgreSQLModel {}

// MARK: - Content
extension Asset: Content {}

// MARK: - Migration
extension Asset: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.recordID, to: \Record.id) // Set up a foreign key
        }
    }
}

// MARK: - Parameter
extension Asset: Parameter {}

// MARK: - Helpers
extension Asset {
    private var record: Parent<Asset, Record> {
        return parent(\.recordID)
    }
}
