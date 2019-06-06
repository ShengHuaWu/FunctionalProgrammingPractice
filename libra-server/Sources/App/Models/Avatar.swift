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
    static func makeURL(with name: String) -> URL {
        let directory = DirectoryConfig.detect()
        let workPath = directory.workDir
        
        return URL(fileURLWithPath: workPath).appendingPathComponent("Resources/Records", isDirectory: true).appendingPathComponent(name, isDirectory: false)
    }
    
    private var record: Parent<Avatar, Record> {
        return parent(\.userID)
    }
    
    var url: URL {
        return Avatar.makeURL(with: name)
    }
    
    func getFileData() throws -> Data {
        let fileManager = FileManager() // TODO: How to handle dependency?
        guard fileManager.fileExists(atPath: url.path) else {
            throw Abort(.notFound)
        }
        
        return try Data(contentsOf: url)
    }
    
    func removeFile() throws -> Avatar {
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
    func makeAvatarFuture(for user: User, on conn: DatabaseConnectable) throws -> Future<Avatar> {
        let name = UUID().uuidString
        let url = Avatar.makeURL(with: name)
        try data.write(to: url)
        
        return Avatar(name: name, userID: try user.requireID()).save(on: conn)
    }
}


