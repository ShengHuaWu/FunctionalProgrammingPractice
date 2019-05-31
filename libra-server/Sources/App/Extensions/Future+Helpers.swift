import Vapor

// MARK: - User Helpers
extension Future where T: User {
    func encryptPassword() throws -> Future<User> {
        return map { try $0.encryptPassword() }
    }
    
    func makePublic() -> Future<User.Public> {
        return map { $0.makePublic() }
    }
    
    func validate(authedUser: User) throws -> Future<T> {
        return flatMap { user in
            guard authedUser.id == user.id else {
                throw Abort(.unauthorized)
            }
            
            return self
        }
    }
    
    func makeAllFriends(on conn: DatabaseConnectable) throws -> Future<[User]> {
        return flatMap { user in
            return try user.makeAllFriendsFuture(on: conn)
        }
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
        return flatMap { record in
            return try record.makeIntactFuture(on: conn)
        }
    }
    
    func makeRemoveAllCompanions(on conn: DatabaseConnectable) -> Future<Void> {
        return flatMap { record in
            return record.makeRemoveAllCompanionsFuture(on: conn)
        }
    }
    
    func validate(creator: User) throws -> Future<T> {
        return flatMap { record in
            guard creator.id == record.creatorID else {
                throw Abort(.unauthorized)
            }
            
            return self
        }
    }
    
    func markAsDeleted(on conn: DatabaseConnectable) -> Future<T> {
        return flatMap { record in
            record.isDeleted = true
            return record.save(on: conn)
        }
    }
    
    func validateDeletion() -> Future<T> {
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
        return map(to: Record.self) { try $0.makeRecord(for: user) }
    }
    
    func makeQueuyCompanions(on conn: DatabaseConnectable) -> Future<[User]> {
        return flatMap(to: [User].self) { body in
            return User.makeQueryFuture(using: body.companionIDs, on: conn)
        }
    }
}

// MARK: - Token Helpers
extension Future where T: Token {
    func makePublicUser(for user: User) -> Future<User.Public> {
        return map { token in
            return user.makePublic(with: token)
        }
    }
}
