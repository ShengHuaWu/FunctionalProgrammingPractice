import Vapor

// TODO: Use this struct as responses to `Attachment` & `Avatar`
struct Asset {
    let id: Int
}

// MARK: - Content
extension Asset: Content {}
