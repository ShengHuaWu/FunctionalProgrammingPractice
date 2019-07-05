// TODO: Separate this file into different files

import Vapor

// MARK: - User Helpers
// TODO: `Accessing` struct
// `authorize(_ user: U, toAccess rescourse: R, as accessing: A)`
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

func queryCompanions(with userIDs: [User.ID], on conn: DatabaseConnectable) -> Future<[User]> {
    return User.query(on: conn).filter(.make(\.id, .in, userIDs)).all()
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

// MARK: - Token Helpers
func revoke(_ token: Token, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
    token.isRevoked = true
    
    return token.save(on: conn).transform(to: .noContent)
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

func convert(_ records: [Record], toIntactsOn conn: DatabaseConnectable) throws -> Future<[Record.Intact]> {
    return try records.map { try convert($0, toIntactOn: conn) }.flatten(on: conn)
}

func removeAllCompanions(of record: Record, on conn: DatabaseConnectable) -> Future<Void> {
    return record.companions.detachAll(on: conn)
}

// Check `creatorID` as well as `isDeleted`
func authorize(_ authenticatedUser: User, hasAccessTo record: Record) throws -> Record {
    guard try authenticatedUser.requireID() == record.creatorID else {
        throw Abort(.unauthorized)
    }
    
    guard !record.isDeleted else {
        throw Abort(.notFound)
    }
    
    return record
}

func mark(_ record: Record, asDeletedOn conn: DatabaseConnectable) -> Future<Record> {
    record.isDeleted = true
    
    return record.save(on: conn)
}

// MARK: - Record Request Body Helpers
func createRecord(with body: Record.RequestBody, for user: User) throws -> Record {
    return try Record(title: body.title, note: body.note, date: body.date, amount: body.amount, currency: body.currency, mood: body.mood, isDeleted: false, creatorID: user.requireID())
}

// MARK: - Attachment Helpers
func check(_ attachment: Attachment, isAttachedTo record: Record) throws -> Attachment {
    guard try record.requireID() == attachment.recordID else {
        throw Abort(.badRequest)
    }
    
    return attachment
}

// TODO: Consider moving to `Attachment`?
func convertToHTTPResponse(from attachment: Attachment) throws -> HTTPResponse {
    return HTTPResponse(body: try Current.resourcePersisting.fetch(attachment.name))
}
