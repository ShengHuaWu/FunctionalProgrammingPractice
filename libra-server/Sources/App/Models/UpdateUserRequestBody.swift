import Vapor

extension User {
    struct UpdateRequestBody: Codable {
        enum CodingKeys: String, CodingKey {
            case firstName = "first_name"
            case lastName = "last_name"
            case email
        }
        
        let firstName: String
        let lastName: String
        let email: String
    }
}

// MARK: - Update User Request Body Content
extension User.UpdateRequestBody: Content {}
