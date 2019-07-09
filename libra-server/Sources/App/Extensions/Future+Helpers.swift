import Vapor

// TODO: Move these methods to `Helpers.swift`

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
