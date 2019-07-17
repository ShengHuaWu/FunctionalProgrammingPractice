// TODO: Separate this file into different files

import Vapor
import FluentPostgreSQL
import Authentication

// MARK: - User Helpers
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

func searchUsers(with key: String, on conn: DatabaseConnectable) -> Future<[User]> {
    return User.query(on: conn).group(.or) { orGroup in
        orGroup.filter(.make(\.firstName, .like, [key]))
        orGroup.filter(.make(\.lastName, .like, [key]))
        orGroup.filter(.make(\.email, .like, [key]))
    }.all()
}

func check(_ user: User, hasFriendshipWith person: User, on conn: DatabaseConnectable) -> Future<Bool> {
    return user.friends.isAttached(person, on: conn)
}

func queryFriend(with id: User.ID, on conn: DatabaseConnectable) -> Future<User?> {
    return User.query(on: conn).filter(.make(\.id, .in, [id])).first()
}

func queryAllFriends(of user: User, on conn: DatabaseConnectable) throws -> Future<[User]> {
    return try user.friends.query(on: conn).all()
}

func addFriendship(between user: User, and person: User, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
    return user.friends.attachSameType(person, on: conn).transform(to: .created)
}

func removeFriendship(between user: User, and person: User, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
    return user.friends.detach(person, on: conn).transform(to: .noContent)
}

func queryCompanions(with userIDs: [User.ID], on conn: DatabaseConnectable) -> Future<[User]> {
    return User.query(on: conn).filter(.make(\.id, .in, userIDs)).all()
}

func queryToken(of user: User, with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<Token?> {
    return try user.authTokens.query(on: conn).group(.and) { andGroup in
        andGroup.filter(\.isRevoked == false)
        andGroup.filter(.make(\.osName, .in, [body.osName]))
        andGroup.filter(.make(\.timeZone, .in, [body.timeZone]))
    }.first()
}

func queryRecords(of user: User, on conn: DatabaseConnectable) throws -> Future<[Record]> {
    return try user.records.query(on: conn).filter(\.isDeleted == false).all()
}

func createNewAvatar(of user: User, with file: File, on conn: DatabaseConnectable) throws -> Future<Avatar> {
    let name = UUID().uuidString
    try Current.resourcePersisting.save(file.data, name)
    
    return try Avatar(name: name, userID: user.requireID()).save(on: conn)
}

private func createNewToken(for user: User, with body: AuthenticationBody) throws -> Token {
    let random = try CryptoRandom().generateData(count: 16)
    
    return try Token(token: random.base64EncodedString(), isRevoked: false, osName: body.osName, timeZone: body.timeZone, userID: user.requireID())
}

// MARK: - Authentication Body Helpers
func signUp(with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<User.Public> {
    guard let userInfo = body.userInfo else {
        throw Abort(.badRequest)
    }
    
    return try User(userInfo: userInfo).encryptPassword().save(on: conn).flatMap { user in
        return try createNewToken(for: user, with: body)
            .save(on: conn)
            .flatMap { try convert(user, toPublicOn: conn, with: $0) }
    }
}

func logIn(for user: User, with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<User.Public> {
    return try queryToken(of: user, with: body, on: conn).map { token in
        guard let unwrappedToken = token else {
            return try createNewToken(for: user, with: body)
        }
        
        return unwrappedToken
    }
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
    let assetsFuture = try record.attachments.query(on: conn).all().map { try $0.map(Asset.init) }
    
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

func mark(_ record: Record, asDeletedOn conn: DatabaseConnectable) -> Future<Record> {
    record.isDeleted = true
    
    return record.save(on: conn)
}

func append(_ companions: [User], to record: Record, on conn: DatabaseConnectable) -> Future<Record> {
    return companions.map { record.companions.attach($0, on: conn) }.flatten(on: conn).map { _ in return record }
}

func createAttachment(of record: Record, with file: File, on conn: DatabaseConnectable) throws -> Future<Attachment> {
    let name = UUID().uuidString
    try Current.resourcePersisting.save(file.data, name)
    
    return Attachment(name: name, recordID: try record.requireID()).save(on: conn)
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

func deleteFile(of attachment: Attachment) throws -> Attachment {
    try Current.resourcePersisting.delete(attachment.name)
    
    return attachment
}

// MARK: - Avatar Helpers
func check(_ avatar: Avatar, isBelongTo user: User) throws -> Avatar {
    guard try user.requireID() == avatar.userID else {
        throw Abort(.badRequest)
    }
    
    return avatar
}

func deleteFile(of avatar: Avatar) throws -> Avatar {
    try Current.resourcePersisting.delete(avatar.name)
    
    return avatar
}
