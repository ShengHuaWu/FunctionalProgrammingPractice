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
    static func makeURL(with name: String) -> URL {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        return URL(fileURLWithPath: workPath).appendingPathComponent("Resources/Records", isDirectory: true).appendingPathComponent(name, isDirectory: false)
    }
    
    private var record: Parent<Asset, Record> {
        return parent(\.recordID)
    }
    
    var url: URL {
        return Asset.makeURL(with: name)
    }
    
    func getFileData() throws -> Data {
        let fileManager = FileManager() // TODO: How to handle dependency?
        guard fileManager.fileExists(atPath: url.path) else {
            throw Abort(.notFound)
        }
        
        return try Data(contentsOf: url)
    }
    
    func removeFile() throws -> Asset {
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
    func makeAssetFuture(for record: Record, on conn: DatabaseConnectable) throws -> Future<Asset> {
        let name = UUID().uuidString
        let url = Asset.makeURL(with: name)
        try data.write(to: url)
        
        return Asset(name: name, recordID: try record.requireID()).save(on: conn)
    }
}
