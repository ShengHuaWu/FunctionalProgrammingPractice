import Vapor

struct AddFriendBody: Decodable {
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
    
    let userID: User.ID
}

// MARK: - Add Friend Body Content
extension AddFriendBody: Content {}
