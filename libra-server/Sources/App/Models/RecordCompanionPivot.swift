import FluentPostgreSQL

final class RecordCompanionPivot: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case companionID = "companion_id"
        case recordID = "record_id"
    }
    
    typealias Left = Record
    typealias Right = User
    
    var id: UUID?
    var companionID: User.ID
    var recordID: Record.ID
    
    static var leftIDKey: WritableKeyPath<RecordCompanionPivot, UUID> {
        return \.recordID
    }
    
    static var rightIDKey: WritableKeyPath<RecordCompanionPivot, UUID> {
        return \.companionID
    }
    
    init(_ left: Record, _ right: User) throws {
        self.recordID = try left.requireID()
        self.companionID = try right.requireID()
    }
}

// MARK: - PostgreSQLUUIDPivot
extension RecordCompanionPivot: PostgreSQLUUIDPivot {}

// MARK: ModifiablePivot
extension RecordCompanionPivot: ModifiablePivot {}

// MARK: - Migration
extension RecordCompanionPivot: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            
            // The pivot (relationship) will be automatically removed,
            // when we delete the companion or record from the database
            builder.reference(from: \.companionID, to: \User.id, onDelete: .cascade)
            builder.reference(from: \.recordID, to: \Record.id, onDelete: .cascade)
        }
    }
}

