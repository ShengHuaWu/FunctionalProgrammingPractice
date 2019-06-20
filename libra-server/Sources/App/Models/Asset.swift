import Vapor

struct Asset {
    let id: Int
}

// MARK: - Content
extension Asset: Content {}
