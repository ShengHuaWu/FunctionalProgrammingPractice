import Foundation
import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case username
        case password
        case email
    }
    
    var id: Int?
    var firstName: String
    var lastName: String
    var username: String
    var password: String
    var email: String
        
    init(firstName: String, lastName: String, username: String, password: String, email: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.password = password
        self.email = email
    }
}

// MARK: - PostgreSQLModel
extension User: PostgreSQLModel {}

// MARK: - Content
extension User: Content {}

// MARK: - Parameter
extension User: Parameter {}

// MARK: - Migration
extension User: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.username) // Add a unique index to username
        }
    }
}

// MARK: - Basic Authenticatable
extension User: BasicAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \.username
    }
    
    static var passwordKey: WritableKeyPath<User, String> {
        return \.password
    }
}

// MARK: - Token Authenticatable
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

// MARK: - Helpers
extension User {
    private var records: Children<User, Record> {
        return children(\.creatorID)
    }
    
    private var friends: Siblings<User, User, FriendshipPivot> {
        return siblings(FriendshipPivot.leftIDKey, FriendshipPivot.rightIDKey)
    }
    
    var avatar: Children<User, Avatar> {
        return children(\.userID)
    }
    
    static func makeQueryFuture(using ids: [User.ID], on conn: DatabaseConnectable) -> Future<[User]> {
        return User.query(on: conn).filter(.make(\.id, .in, ids)).all()
    }
    
    static func makeSingleQueryFuture(using id: User.ID, on conn: DatabaseConnectable) -> Future<User?> {
        return User.query(on: conn).filter(.make(\.id, .in, [id])).first()
    }
    
    static func makeSearchQueryFuture(using key: String, on conn: DatabaseConnectable) -> Future<[User]> {
        return User.query(on: conn).group(.or) { orGroup in
            orGroup.filter(.make(\.firstName, .like, [key]))
            orGroup.filter(.make(\.lastName, .like, [key]))
            orGroup.filter(.make(\.email, .like, [key]))
        }.all()
    }
    
    private func makeQueryTokenFuture(with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<Token?> {
        return try authTokens.query(on: conn).group(.and) { andGroup in
            andGroup.filter(\.isRevoked == false)
            andGroup.filter(.make(\.osName, .in, [body.osName]))
            andGroup.filter(.make(\.timeZone, .in, [body.timeZone]))
        }.first()
    }
    
    static func customTokenAuthMiddleware() -> CustomTokenAuthenticationMiddleware {
        return CustomTokenAuthenticationMiddleware()
    }
    
    func encryptPassword() throws -> User {
        password = try BCrypt.hash(password)
        return self
    }
    
    func update(with body: UpdateRequestBody) -> User {
        firstName = body.firstName
        lastName = body.lastName
        email = body.email
        
        return self
    }
    
    func makeTokenFuture(with body: AuthenticationBody, on conn: DatabaseConnectable) throws -> Future<Token> {
        // TODO: Refresh token?
        return try makeQueryTokenFuture(with: body, on: conn).map { token in
            guard let unwrappedToken = token else {
                let random = try CryptoRandom().generateData(count: 16)
                
                return try Token(token: random.base64EncodedString(), isRevoked: false, osName: body.osName, timeZone: body.timeZone, userID: self.requireID())
            }
            
            return unwrappedToken
        }
    }
    
    func makeAllUndeletedRecordsFuture(on conn: DatabaseConnectable) throws -> Future<[Record]> {
        return try records.query(on: conn).filter(\.isDeleted == false).all()
    }
    
    func makeAllFriendsFuture(on conn: DatabaseConnectable) throws -> Future<[User]> {
        return try friends.query(on: conn).all()
    }
    
    func makeHasFriendshipFuture(with person: User, on conn: DatabaseConnectable) -> Future<Bool> {
        return friends.isAttached(person, on: conn)
    }
    
    func makeAddFriendshipFuture(to person: User, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return friends.attachSameType(person, on: conn).transform(to: .created)
    }
    
    func makeRemoveFriendshipFuture(to person: User, on conn: DatabaseConnectable) -> Future<HTTPStatus> {
        return friends.detach(person, on: conn).transform(to: .noContent)
    }
    
    func makeAvatarFuture(with file: File, on conn: DatabaseConnectable) throws -> Future<Avatar> {
        let name = UUID().uuidString
        try Current.resourcePersisting.save(file.data, name)
        
        return Avatar(name: name, userID: try requireID()).save(on: conn)
    }
}

// TODO: To be removed (Only used for attaching friends because they are the same type)
extension Siblings
    where Through: ModifiablePivot, Through.Left == Base, Through.Right == Related, Through.Left == Through.Right, Through.Database: QuerySupporting
{
    func attachSameType(_ model: Related, on conn: DatabaseConnectable) -> Future<Through> {
        return Future.flatMap(on: conn) {
            let pivot = try Through(self.base, model)
            return pivot.save(on: conn)
        }
    }
}
