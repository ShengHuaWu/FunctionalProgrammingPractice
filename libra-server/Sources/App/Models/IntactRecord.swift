import Vapor

extension Record {
    struct Intact: Codable {
        let id: UUID?
        let title: String
        let note: String
        let date: Date
        let amount: Double
        let currency: String
        let mood: String
        let creator: User.Public
        let companions: [User.Public]
    }
}

// MARK: - Intact Record Content
extension Record.Intact: Content {}
