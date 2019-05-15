struct FriendshipParameters: Encodable {
    enum CodingKeys: String, CodingKey {
        case personID = "person_id"
    }
    
    let userID: Int
    let personID: Int // Use this property as `friendID` for get one friend or remove friendship
}
