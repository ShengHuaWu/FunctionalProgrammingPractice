import Vapor

// TODO: Move these methods to `Helpers.swift`

// MARK: - Record Request Body Helpers
extension Future where T == Record.RequestBody {
    func makeRecord(for user: User) throws -> Future<Record> {
        return map { try $0.makeRecord(for: user) }
    }
    
    func makeQueuyCompanions(on conn: DatabaseConnectable) -> Future<[User]> {
        return flatMap { User.makeQueryFuture(using: $0.companionIDs, on: conn) }
    }
}

// MARK: - Attachment Helpers
extension Future where T: Attachment {
    func isAttached(to record: Record) throws -> Future<T> {
        return map { attachment in
            guard try record.requireID() == attachment.recordID else {
                throw Abort(.badRequest)
            }
            
            return attachment
        }
    }
    
    func makeDownloadHTTPResponse() -> Future<HTTPResponse> {
        return map { HTTPResponse(body: try Current.resourcePersisting.fetch($0.name)) }
    }
    
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
