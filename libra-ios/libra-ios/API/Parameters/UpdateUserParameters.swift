struct UpdateUserParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
    }
    
    let userID: Int
    let firstName: String
    let lastName: String
    let email: String
}
