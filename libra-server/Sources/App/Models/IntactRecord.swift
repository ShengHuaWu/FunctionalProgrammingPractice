import Vapor

extension Record {
    struct Intact: Codable {
        let id: Int?
        let title: String
        let note: String
        let date: Date
        let amount: Double
        let currency: String
        let mood: String
        let creator: User.Public
        let companions: [User.Public]
        let assets: [Asset]
    }
}

// MARK: - Intact Record Content
extension Record.Intact: Content {}
