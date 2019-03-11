import Vapor
import FluentPostgreSQL

final class Record: Codable {
    var id: UUID?
    var title: String
    var description: String?
    var date: Date
    
    // TODO: `category`, `creator`, `contributor`, `attachments` properties
    
    init(title: String, description: String?, date: Date) {
        self.title = title
        self.description = description
        self.date = date
    }
}

// MARK: - PostgreSQLUUIDModel
extension Record: PostgreSQLUUIDModel {}

// MARK: - Content
extension Record: Content {}

// MARK: - Migration
extension Record: Migration {}
