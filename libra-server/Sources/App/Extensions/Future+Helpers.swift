import Vapor

// TODO: Move these methods to `Helpers.swift`

// MARK: - User Helpers
extension Future where T == [User] {
    func makePublics(on conn: DatabaseConnectable) -> Future<[User.Public]> {
        return flatMap { try $0.map { try makePublicUserFuture(for: $0, on: conn) }.flatten(on: conn) }
    }
}

// MARK: - Authentication Body Helpers
extension Future where T == AuthenticationBody {
    func signUp(on conn: DatabaseConnectable) throws -> Future<User.Public> {
        return flatMap { body in
            guard let userInfo = body.userInfo else {
                throw Abort(.badRequest)
            }
            
            return try userInfo.makeUser().encryptPassword().save(on: conn).flatMap { user in
                return try user.makeTokenFuture(with: body, on: conn).save(on: conn).flatMap { try makePublicUserFuture(for: user, with: $0, on: conn) }
            }
        }
    }
    
    func logIn(for user: User, on conn: DatabaseConnectable) -> Future<User.Public> {
        return flatMap { try user.makeTokenFuture(with: $0, on: conn).save(on: conn).flatMap { try makePublicUserFuture(for: user, with: $0, on: conn) } }
    }
}

// MARK: - Record Helpers
extension Future where T: Record {
    func makeIntact(on conn: DatabaseConnectable) throws -> Future<Record.Intact> {
        return flatMap { try $0.makeIntactFuture(on: conn) }
    }
    
    func makeRemoveAllCompanions(on conn: DatabaseConnectable) -> Future<Void> {
        return flatMap { $0.makeRemoveAllCompanionsFuture(on: conn) }
    }
    
    func isOwned(by creator: User) throws -> Future<T> {
        return map { record in
            guard try creator.requireID() == record.creatorID else {
                throw Abort(.unauthorized)
            }
            
            return record
        }
    }
    
    func markAsDeleted(on conn: DatabaseConnectable) -> Future<T> {
        return flatMap { record in
            record.isDeleted = true
            return record.save(on: conn)
        }
    }
    
    func isDeleted() -> Future<T> {
        return map { record in
            guard !record.isDeleted else {
                throw Abort(.notFound)
            }
            
            return record
        }
    }
}

extension Future where T == [Record] {
    func makeIntacts(on conn: DatabaseConnectable) throws -> Future<[Record.Intact]> {
        return flatMap { records in
            return try records.map { try $0.makeIntactFuture(on: conn) }.flatten(on: conn)
        }
    }
}

// MARK: - Record Request Body Helpers
extension Future where T == Record.RequestBody {
    func makeRecord(for user: User) throws -> Future<Record> {
        return map { try $0.makeRecord(for: user) }
    }
    
    func makeQueuyCompanions(on conn: DatabaseConnectable) -> Future<[User]> {
        return flatMap { User.makeQueryFuture(using: $0.companionIDs, on: conn) }
    }
}

// MARK: - Token Helpers
extension Future where T: Token {
    func revoke(on conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return flatMap { token in
            token.isRevoked = true
            return token.save(on: conn).transform(to: .noContent)
        }
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
