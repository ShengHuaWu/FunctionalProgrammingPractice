struct AddFriendshipParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case personID = "person_id"
    }
    
    let userID: Int
    let personID: Int
}
