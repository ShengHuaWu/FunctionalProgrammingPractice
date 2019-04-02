import FluentPostgreSQL

// TODO: Change to `RecordCompanionPivot`
final class CompanionRecordPivot: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case companionID = "companion_id"
        case recordID = "record_id"
    }
    
    typealias Left = User
    typealias Right = Record
    
    var id: UUID?
    var companionID: User.ID
    var recordID: Record.ID
    
    static var leftIDKey: WritableKeyPath<CompanionRecordPivot, UUID> {
        return \.companionID
    }
    
    static var rightIDKey: WritableKeyPath<CompanionRecordPivot, UUID> {
        return \.recordID
    }
    
    init(_ left: User, _ right: Record) throws {
        self.companionID = try left.requireID()
        self.recordID = try right.requireID()
    }
}

// MARK: - PostgreSQLUUIDPivot
extension CompanionRecordPivot: PostgreSQLUUIDPivot {}

// MARK: ModifiablePivot
extension CompanionRecordPivot: ModifiablePivot {}

// MARK: - Migration
extension CompanionRecordPivot: Migration {}
