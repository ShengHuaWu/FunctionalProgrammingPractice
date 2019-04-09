import Vapor

// MARK: - User Helpers
extension Future where T: User {
    func encryptPassword() throws -> Future<User> {
        return map { try $0.encryptPassword() }
    }
    
    func makePublic() -> Future<User.Public> {
        return map { $0.makePublic() }
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
}

// MARK: - Record Request Body Helpers
extension Future where T == Record.RequestBody {
    func makeRecord() -> Future<Record> {
        return map(to: Record.self) { $0.makeRecord() }
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
