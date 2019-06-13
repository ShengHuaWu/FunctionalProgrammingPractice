import Vapor

// MARK: - User Helpers
extension Future where T: User {
    func encryptPassword() throws -> Future<User> {
        return map { try $0.encryptPassword() }
    }
    
    func makePublic() -> Future<User.Public> {
        return map { $0.makePublic() }
    }
    
    func isAuthorized(by authedUser: User) throws -> Future<T> {
        return flatMap { user in
            guard authedUser.id == user.id else {
                throw Abort(.unauthorized)
            }
            
            return self
        }
    }
    
    func makeAllFriends(on conn: DatabaseConnectable) throws -> Future<[User]> {
        return flatMap { try $0.makeAllFriendsFuture(on: conn) }
    }
}

extension Future where T == [User] {
    func makePublics() -> Future<[User.Public]> {
        return map { $0.map { $0.makePublic() } }
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
    func makePublicUser(for user: User) -> Future<User.Public> {
        return map { user.makePublic(with: $0) }
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
        return map { HTTPResponse(body: try $0.getFileData()) }
    }
    
    func deleteFile(on conn: DatabaseConnectable) -> Future<Attachment> {
        return map { try $0.removeFile() }
    }
}

extension Future where T == [Attachment] {
    func makeAssets() -> Future<[Asset]> {
        return map { try $0.map { Asset(id: try $0.requireID()) } }
    }
}
