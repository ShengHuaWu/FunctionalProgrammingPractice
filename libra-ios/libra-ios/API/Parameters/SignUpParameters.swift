import Foundation

struct SignUpParameters: Encodable {
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
