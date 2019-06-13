import Vapor
import FluentPostgreSQL

final class Attachment: Codable {
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
extension Attachment: PostgreSQLModel {}

// MARK: - Content
extension Attachment: Content {}

// MARK: - Migration
extension Attachment: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.recordID, to: \Record.id) // Set up a foreign key
        }
    }
}

// MARK: - Parameter
extension Attachment: Parameter {}

// MARK: - Helpers
extension Attachment {
    private var record: Parent<Attachment, Record> {
        return parent(\.recordID)
    }
}

// MARK: - File Helpers
// TODO: Move to another file?
extension File {
    func makeAttachmentFuture(for record: Record, on conn: DatabaseConnectable) throws -> Future<Attachment> {
        let name = UUID().uuidString
        try Current.resourcesService.save(data, name)
        
        return Attachment(name: name, recordID: try record.requireID()).save(on: conn)
    }
}
