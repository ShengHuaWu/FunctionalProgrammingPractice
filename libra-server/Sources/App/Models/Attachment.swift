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
// TODO: Merge with `Avatar`
extension Attachment {
    static func makeURL(with name: String) -> URL {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        return URL(fileURLWithPath: workPath).appendingPathComponent("Resources/Records", isDirectory: true).appendingPathComponent(name, isDirectory: false)
    }
    
    private var record: Parent<Attachment, Record> {
        return parent(\.recordID)
    }
    
    var url: URL {
        return Attachment.makeURL(with: name)
    }
    
    func getFileData() throws -> Data {
        let fileManager = FileManager() // TODO: How to handle dependency?
        guard fileManager.fileExists(atPath: url.path) else {
            throw Abort(.notFound)
        }
        
        return try Data(contentsOf: url)
    }
    
    func removeFile() throws -> Attachment {
        let fileManager = FileManager() // TODO: How to handle dependency?
        guard fileManager.fileExists(atPath: url.path) else {
            throw Abort(.notFound)
        }
        
        try fileManager.removeItem(at: url)
        
        return self
    }
}

// MARK: - File Helpers
extension File {
    func makeAttachmentFuture(for record: Record, on conn: DatabaseConnectable) throws -> Future<Attachment> {
        let name = UUID().uuidString
        let url = Attachment.makeURL(with: name)
        try data.write(to: url)
        
        return Attachment(name: name, recordID: try record.requireID()).save(on: conn)
    }
}

