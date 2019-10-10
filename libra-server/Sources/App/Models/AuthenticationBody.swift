import Vapor

struct AuthenticationBody: Codable {
    enum CodingKeys: String, CodingKey {
        case userInfo = "user_info"
        case osName = "os_name"
        case timeZone = "time_zone"
    }
    
    let userInfo: UserInfo?
    let osName: String
    let timeZone: String
}

extension AuthenticationBody {
    struct UserInfo: Codable {
        enum CodingKeys: String, CodingKey {
            case username
            case password
            case firstName = "first_name"
            case lastName = "last_name"
            case email
        }
        
        let username: String
        let password: String
        let firstName: String
        let lastName: String
        let email: String
    }
}

// MARK: - Content
extension AuthenticationBody: Content {}

extension AuthenticationBody.UserInfo: Content {}
