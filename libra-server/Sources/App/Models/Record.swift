import Vapor
import FluentPostgreSQL

final class Record: Codable {
    enum Category {
        case expense(Double) // TODO: Consider currency
        case other(String)
    }
    
    enum Mood: String, Codable {
        case good
        case neutral
        case bad
        // TODO: Maybe `upset`, `sad`, `clam`, etc...
        // http://quantifiedself.com/2012/12/how-is-mood-measured-get-your-mood-on-part-2/
    }
    
    // TODO: Add `category` and `mood` back
    // Consider `struct Category` and `enum Mood: PostgreSQLEnum`
    
    var id: UUID?
//    var category: Category
    var title: String
    var note: String
    var date: Date
//    var mood: Mood
    
    // TODO: `creator`, `partners`, `attachments` properties
    init(title: String, note: String, date: Date) {
//        self.category = category
        self.title = title
        self.note = note
        self.date = date
//        self.mood = mood
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
    /*
     Examples: ["expense": 21.05], ["other": "whatever it is"]
     */
    
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
