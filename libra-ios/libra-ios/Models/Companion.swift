// TODO: Merge this type by `User` with custom decoding (maybe rename to `Person`)
struct Companion: Decodable {
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
