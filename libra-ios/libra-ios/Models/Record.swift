import Foundation

struct Record: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case note
        case date
        case amount
        case _currency = "currency"
        case _mood = "mood"
    }
    
    let id: Int
    let title: String
    let note: String
    let date: Date
    let amount: Double
    private let _currency: String
    private let _mood: String
    
    var currency: Currency {
        return Currency(rawValue: _currency) ?? .unknown
    }
    
    var mood: Mood {
        return Mood(rawValue: _mood) ?? .unknown
    }
    
    init(id: Int, title: String, note: String, date: Date, amount: Double, currency: Currency, mood: Mood) {
        self.id = id
        self.title = title
        self.note = note
        self.date = date
        self.amount = amount
        self._currency = currency.rawValue
        self._mood = mood.rawValue
    }
}

extension Record {
    enum Currency: String {
        case usd
        case euro
        case unknown
    }
    
    enum Mood: String {
        case good
        case bad
        case unknown
    }
}
