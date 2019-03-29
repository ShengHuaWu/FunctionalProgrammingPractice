import Vapor
import FluentPostgreSQL

final class Record: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case note
        case date
        case amount
        case _currency = "currency"
        case _mood = "mood"
        case creatorID = "creator_id"
    }
    
    enum Currency: String {
        case euro
        case usd
        case none
        // TODO: Support more currencies
    }
    
    enum Mood: String {
        case good
        case neutral
        case bad
        case unknown
        // TODO: Maybe `upset`, `sad`, `clam`, etc...
        // http://quantifiedself.com/2012/12/how-is-mood-measured-get-your-mood-on-part-2/
    }
    
    var id: UUID?
    var title: String
    var note: String
    var date: Date
    var amount: Double
    private var _currency: String
    private var _mood: String
    var creatorID: User.ID // Create a parent-child relationship
    
    var mood: Mood {
        set {
            _mood = newValue.rawValue
        }
        get {
            return Mood(rawValue: _mood) ?? .unknown
        }
    }
    
    var currency: Currency {
        set {
            _currency = newValue.rawValue
        }
        
        get {
            return Currency(rawValue: _currency) ?? .none
        }
    }
    
    // TODO: `companions` (sibling relationship) and `attachments` properties
    init(title: String, note: String, date: Date, amount: Double = 0.0, currency: Currency, mood: Mood, userID: User.ID) {
        self.title = title
        self.note = note
        self.date = date
        self.amount = amount
        self._currency = currency.rawValue
        self._mood = mood.rawValue
        self.creatorID = userID
    }
}

// MARK: - PostgreSQLUUIDModel
extension Record: PostgreSQLUUIDModel {}

// MARK: - Content
extension Record: Content {}

// MARK: - Migration
extension Record: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.creatorID, to: \User.id) // Set up a foreign key
        }
    }
}

// MARK: - Parameter
extension Record: Parameter {}

// MARK: - Helpers
extension Record {
    var creator: Parent<Record, User> {
        return parent(\.creatorID)
    }
}
