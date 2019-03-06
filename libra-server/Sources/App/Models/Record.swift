import Vapor
import FluentPostgreSQL

final class Record: Codable {
    var id: UUID?
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

// MARK: - PostgreSQLUUIDModel
extension Record: PostgreSQLUUIDModel {}

// MARK: - Content
extension Record: Content {}

// MARK: - Migration
extension Record: Migration {}
