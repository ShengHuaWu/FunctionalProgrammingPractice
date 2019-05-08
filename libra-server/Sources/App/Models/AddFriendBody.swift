import Vapor

struct AddFriendBody: Decodable {
    enum CodingKeys: String, CodingKey {
        case personID = "person_id"
    }
    
    let personID: User.ID
}

// MARK: - Add Friend Body Content
extension AddFriendBody: Content {}
