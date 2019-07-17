import Vapor

struct Asset {
    let id: Int
}

// MARK: - Content
extension Asset: Content {}

// MARK: - Helpers
extension Asset {
    init(avatar: Avatar) throws {
        try self.init(id: avatar.requireID())
    }
    
    init(attachment: Attachment) throws {
        try self.init(id: attachment.requireID())
    }
}
