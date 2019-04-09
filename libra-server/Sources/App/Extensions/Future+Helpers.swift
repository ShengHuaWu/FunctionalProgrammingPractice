import Vapor

// MARK: - User Helpers
extension Future where T: User {
    func makePublic() -> Future<User.Public> {
        return map(to: User.Public.self) { $0.makePublic() }
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
    func makeLoginResponse(on conn: DatabaseConnectable) -> Future<LoginResponse> {
        return flatMap(to: LoginResponse.self) { token in
            return token.authUser.get(on: conn).map(to: LoginResponse.self) { user in
                return LoginResponse(id: user.id, firstName: user.firstName, lastName: user.lastName, username: user.username, email: user.email, token: token.token)
            }
        }
    }
}
