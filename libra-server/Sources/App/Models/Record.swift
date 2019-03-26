import Vapor
import FluentPostgreSQL

final class Record: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case note
        case date
        case amount
        case currency
        case _mood = "mood"
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
    var currency: String?
    private var _mood: String
    
    var mood: Mood {
        set {
            _mood = newValue.rawValue
        }
        get {
            return Mood(rawValue: _mood) ?? .unknown
        }
    }
    
    // TODO: `creator`, `partners`, `attachments` properties
    init(title: String, note: String, date: Date, amount: Double = 0.0, currency: String? = nil, mood: Mood) {
        self.title = title
        self.note = note
        self.date = date
        self.amount = amount
        self.currency = currency
        self._mood = mood.rawValue
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
