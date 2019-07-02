// TODO: Separate this file into different files

import Vapor

// MARK: - User Helpers
func authorize(_ authenticatedUser: User, hasAccessTo user: User) throws -> User {
    guard authenticatedUser.id == user.id else {
        throw Abort(.unauthorized)
    }
    
    return user
}

func convert(_ user: User, toPublicOn conn: DatabaseConnectable, with token: Token? = nil) throws -> Future<User.Public> {
    let avatarFuture = try user.avatar.query(on: conn).first()
    
    return avatarFuture.map(to: User.Public.self) { avatar in
        let asset = try avatar.map { Asset(id: try $0.requireID()) }
        
        return User.Public(id: user.id, firstName: user.firstName, lastName: user.lastName, username: user.username, email: user.email, token: token?.token, asset: asset)
    }
}

func convert(_ users: [User], toPublicsOn conn: DatabaseConnectable) throws -> Future<[User.Public]> {
    return try users.map { try convert($0, toPublicOn: conn) }.flatten(on: conn)
}

func queryAllFriends(of user: User, on conn: DatabaseConnectable) throws -> Future<[User]> {
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
            .flatMap { try convert(user, toPublicOn: conn, with: $0) }
    }
}

func logIn(for user: User, with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<User.Public> {
    return try user.makeTokenFuture(with: body, on: conn)
        .save(on: conn)
        .flatMap { try convert(user, toPublicOn: conn, with: $0) }
}

// MARK: - Record Helpers
func convert(_ record: Record, toIntactOn conn: DatabaseConnectable) throws -> Future<Record.Intact> {
    let creatorFuture = record.creator.get(on: conn).flatMap { try convert($0, toPublicOn: conn) }
    let companionsFuture = try record.companions.query(on: conn).all().flatMap { try convert($0, toPublicsOn: conn) }
    let assetsFuture = try record.attachments.query(on: conn).all().makeAssets()
    
    return map(to: Record.Intact.self, creatorFuture, companionsFuture, assetsFuture) { creator, companions, assets in
        return Record.Intact(id: record.id, title: record.title, note: record.note, date: record.date, amount: record.amount, currency: record.currency, mood: record.mood, creator: creator, companions: companions, assets: assets)
    }
}
