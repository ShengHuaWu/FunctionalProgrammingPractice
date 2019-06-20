import Vapor

// MARK: - Public User
extension User {
    struct Public: Codable {
        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
            case username
            case email
            case token
            case asset
        }
        
        let id: Int?
        let firstName: String
        let lastName: String
        let username: String
        let email: String
        let token: String?
        let asset: Asset?
    }
}

// MARK: - Public User Content
extension User.Public: Content {}
