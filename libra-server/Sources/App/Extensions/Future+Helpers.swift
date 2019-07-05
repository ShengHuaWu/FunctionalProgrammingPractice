import Vapor

// TODO: Move these methods to `Helpers.swift`

// MARK: - Attachment Helpers
extension Future where T: Attachment {
    func deleteFile(on conn: DatabaseConnectable) -> Future<T> {
        return map { attachment in
            try Current.resourcePersisting.delete(attachment.name)
            
            return attachment
        }
    }
    
    func makeAsset() -> Future<Asset> {
        return map { Asset(id: try $0.requireID()) }
    }
}

extension Future where T == [Attachment] {
    func makeAssets() -> Future<[Asset]> {
        return map { try $0.map { Asset(id: try $0.requireID()) } }
    }
}

// MARK: - Avatar Helpers
extension Future where T: Avatar {
    func isBelong(to user: User) throws -> Future<T> {
        return map { avatar in
            guard try user.requireID() == avatar.userID else {
                throw Abort(.badRequest)
            }
            
            return avatar
        }
    }
    
    func makeDownloadHTTPResponse() -> Future<HTTPResponse> {
        return map { HTTPResponse(body: try Current.resourcePersisting.fetch($0.name)) }
    }
    
    func deleteFile(on conn: DatabaseConnectable) -> Future<T> {
        return map { avatar in
            try Current.resourcePersisting.delete(avatar.name)
            
            return avatar
        }
    }
    
    func makeAsset() -> Future<Asset> {
        return map { Asset(id: try $0.requireID()) }
    }
}
