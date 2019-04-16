import Foundation

struct User: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
    
    let id: Int
    let username: String
    let firstName: String
    let lastName: String
    let email: String
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.username == rhs.username && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName && lhs.email == rhs.email
    }
}
