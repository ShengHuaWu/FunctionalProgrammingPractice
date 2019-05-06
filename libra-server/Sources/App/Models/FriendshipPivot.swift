import FluentPostgreSQL

final class FriendshipPivot: Codable {
    typealias Left = User
    typealias Right = User
    
    var id: Int?
    var personID: User.ID
    var friendID: User.ID
    
    static var leftIDKey: WritableKeyPath<FriendshipPivot, Int> {
        return \.personID
    }
    
    static var rightIDKey: WritableKeyPath<FriendshipPivot, Int> {
        return \.friendID
    }
    
    init(_ left: User, _ right: User) throws {
        self.personID = try left.requireID()
        self.friendID = try right.requireID()
    }
}

// MARK: - PostgreSQLPivot
extension FriendshipPivot: PostgreSQLPivot {}

// MARK: ModifiablePivot
extension FriendshipPivot: ModifiablePivot {}

// MARK: - Migration
extension FriendshipPivot: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            
            // The pivot (relationship) will be automatically removed,
            // when we delete the person or friend from the database
            builder.reference(from: \.personID, to: \User.id, onDelete: .cascade)
            builder.reference(from: \.friendID, to: \User.id, onDelete: .cascade)
        }
    }
}
