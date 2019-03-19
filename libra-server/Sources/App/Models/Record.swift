import Vapor
import FluentPostgreSQL

final class Record: Codable {
    enum Category {
        case expense(Double)
        case other(String)
    }
    
    var id: UUID?
    var category: Category
    var title: String
    var note: String?
    var date: Date
    
    // TODO: `creator`, `contributor`, `attachments` properties
    
    init(category: Category, title: String, note: String?, date: Date) {
        self.category = category
        self.title = title
        self.note = note
        self.date = date
    }
}

// MARK: - PostgreSQLUUIDModel
extension Record: PostgreSQLUUIDModel {}

// MARK: - Content
extension Record: Content {}

// MARK: - Migration
extension Record: Migration {}

// MARK: - Parameter
extension Record: Parameter {}

// MARK: - Record Category Codable
extension Record.Category: Codable {
    enum CodingKeys: String, CodingKey {
        case expense
        case other
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let amount = try container.decodeIfPresent(Double.self, forKey: .expense) {
            self = .expense(amount)
        } else if let name = try container.decodeIfPresent(String.self, forKey: .other) {
            self = .other(name)
        } else {
            self = .other(try container.decode(String.self, forKey: .other))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .expense(let amount):
            try container.encode(amount, forKey: .expense)
        case .other(let name):
            try container.encode(name, forKey: .other)
        }
    }
}
