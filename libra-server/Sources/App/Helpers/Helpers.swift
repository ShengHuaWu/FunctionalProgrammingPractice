// TODO: Separate this file into different files

import Vapor

// MARK: - User Helpers
func authorize(_ authenticatedUser: User, hasAccessTo user: User) throws -> User {
    guard authenticatedUser.id == user.id else {
        throw Abort(.unauthorized)
    }
    
    return user
}

func makePublicUserFuture(for user: User, with token: Token? = nil, on conn: DatabaseConnectable) throws -> Future<User.Public> {
    let avatarFuture = try user.avatar.query(on: conn).first()
    
    return avatarFuture.map(to: User.Public.self) { avatar in
        let asset = try avatar.map { Asset(id: try $0.requireID()) }
        
        return User.Public(id: user.id, firstName: user.firstName, lastName: user.lastName, username: user.username, email: user.email, token: token?.token, asset: asset)
    }
}

func makeQueryAllFriendsFuture(for user: User, on conn: DatabaseConnectable) throws -> Future<[User]> {
    return try user.friends.query(on: conn).all()
}
