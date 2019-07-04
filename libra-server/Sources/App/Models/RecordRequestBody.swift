import Vapor

extension Record {
    struct RequestBody: Codable {
        enum CodingKeys: String, CodingKey {
            case title
            case note
            case date
            case amount
            case currency
            case mood
            case companionIDs = "companion_ids"
        }
        
        let title: String
        let note: String
        let date: Date
        let amount: Double
        let currency: String
        let mood: String
        let companionIDs: [User.ID]
    }
}

// MARK: - Record Request Body Content
extension Record.RequestBody: Content {}
