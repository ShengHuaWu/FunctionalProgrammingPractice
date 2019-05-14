struct User {
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case token
    }
    
    let person: Person
    let token: String? // Only used for signup & login APIs
    
    // TODO: Need one `shouldSync` or `isChanged` property
    // The same in `Record` & `Person`
}

extension User: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try container.decodeIfPresent(String.self, forKey: .token)
        
        let id = try container.decode(Int.self, forKey: .id)
        let username = try container.decode(String.self, forKey: .username)
        let firstName = try container.decode(String.self, forKey: .firstName)
        let lastName = try container.decode(String.self, forKey: .lastName)
        let email = try container.decode(String.self, forKey: .email)
        self.person = Person(id: id, username: username, firstName: firstName, lastName: lastName, email: email)
    }
}

extension User: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Should NOT include token for local storage
//        try container.encodeIfPresent(token, forKey: .token)
        try container.encode(person.id, forKey: .id)
        try container.encode(person.username, forKey: .username)
        try container.encode(person.firstName, forKey: .firstName)
        try container.encode(person.lastName, forKey: .lastName)
        try container.encode(person.email, forKey: .email)
    }
}
