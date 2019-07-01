// TODO: Separate this file into different files

import Vapor

// MARK: - User Helpers
func authorize(_ authenticatedUser: User, hasAccessTo user: User) throws -> User {
    guard authenticatedUser.id == user.id else {
        throw Abort(.unauthorized)
    }
    
    return user
}

func makePublicUser(for user: User, with token: Token? = nil, on conn: DatabaseConnectable) throws -> Future<User.Public> {
    let avatarFuture = try user.avatar.query(on: conn).first()
    
    return avatarFuture.map(to: User.Public.self) { avatar in
        let asset = try avatar.map { Asset(id: try $0.requireID()) }
        
        return User.Public(id: user.id, firstName: user.firstName, lastName: user.lastName, username: user.username, email: user.email, token: token?.token, asset: asset)
    }
}

func makePublicUsers(for users: [User], on conn: DatabaseConnectable) throws -> Future<[User.Public]> {
    return try users.map { try makePublicUser(for: $0, on: conn) }.flatten(on: conn)
}

func queryAllFriends(for user: User, on conn: DatabaseConnectable) throws -> Future<[User]> {
    return try user.friends.query(on: conn).all()
}

// MARK: - Authentication Body Helpers
func signUp(with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<User.Public> {
    guard let userInfo = body.userInfo else {
        throw Abort(.badRequest)
    }
    
    return try userInfo.makeUser().encryptPassword().save(on: conn).flatMap { user in
        return try user.makeTokenFuture(with: body, on: conn)
            .save(on: conn)
            .flatMap { try makePublicUser(for: user, with: $0, on: conn) }
    }
}

func logIn(for user: User, with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<User.Public> {
    return try user.makeTokenFuture(with: body, on: conn)
        .save(on: conn)
        .flatMap { try makePublicUser(for: user, with: $0, on: conn) }
}
