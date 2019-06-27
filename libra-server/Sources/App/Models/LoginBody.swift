import Vapor

struct LoginBody: Decodable {
    enum CodingKeys: String, CodingKey {
        case osName = "os_name"
        case timeZone = "time_zone"
    }
    
    let osName: String
    let timeZone: String
}

// MARK: - Content
extension LoginBody: Content {}
