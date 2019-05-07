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
    
    func makeDetachAllCompanions(on conn: DatabaseConnectable) -> Future<Void> {
        return flatMap { record in
            return record.companions.detachAll(on: conn)
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
