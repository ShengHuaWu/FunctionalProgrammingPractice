import Vapor

extension User {
    struct Public: Codable {
        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
            case username
            case email
        }
        
        let id: Int?
        let firstName: String
        let lastName: String
        let username: String
        let email: String
    }
}

// MARK: - Public User Content
extension User.Public: Content {}
