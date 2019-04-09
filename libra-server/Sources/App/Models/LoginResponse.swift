import Vapor

struct LoginResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case email
        case token
    }
    
    let id: Int?
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let token: String
}

// MARK: Login Response Content
extension LoginResponse: Content {}
