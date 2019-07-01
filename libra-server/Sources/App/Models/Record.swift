import Vapor
import FluentPostgreSQL

final class Record: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case note
        case date
        case amount
        case currency
        case mood
        case isDeleted = "is_deleted"
        case creatorID = "creator_id"
    }
    
    var id: Int?
    var title: String
    var note: String
    var date: Date
    var amount: Double
    var currency: String
    var mood: String
    var isDeleted: Bool
    var creatorID: User.ID // This creates a parent-child relationship
    
    init(title: String, note: String, date: Date, amount: Double = 0.0, currency: String, mood: String, isDeleted: Bool, creatorID: User.ID) {
        self.title = title
        self.note = note
        self.date = date
        self.amount = amount
        self.currency = currency
        self.mood = mood
        self.isDeleted = isDeleted
        self.creatorID = creatorID
    }
}

// MARK: - PostgreSQLModel
extension Record: PostgreSQLModel {}

// MARK: - Content
extension Record: Content {}

// MARK: - Migration
extension Record: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: conn) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.creatorID, to: \User.id) // Set up a foreign key
        }
    }
}

// MARK: - Parameter
extension Record: Parameter {}

// MARK: - Helpers
extension Record {
    private var creator: Parent<Record, User> {
        return parent(\.creatorID)
    }
    
    private var attachments: Children<Record, Attachment> {
        return children(\.recordID)
    }
    
    private var companions: Siblings<Record, User, RecordCompanionPivot> {
        return siblings()
    }
    
    func update(with body: RequestBody) -> Record {
        title = body.title
        note = body.note
        date = body.date
        amount = body.amount
        currency = body.currency
        mood = body.mood
        
        return self
    }
    
    func makeIntactFuture(on conn: DatabaseConnectable) throws -> Future<Intact> {
        let creatorFuture = creator.get(on: conn).flatMap { try makePublicUser(for: $0, on: conn) } 
        let companionsFuture = try companions.query(on: conn).all().flatMap { try makePublicUsers(for: $0, on: conn) }
        let assetsFuture = try attachments.query(on: conn).all().makeAssets()
        
        return map(to: Intact.self, creatorFuture, companionsFuture, assetsFuture) { creator, companions, assets in
            return Intact(id: self.id, title: self.title, note: self.note, date: self.date, amount: self.amount, currency: self.currency, mood: self.mood, creator: creator, companions: companions, assets: assets)
        }
    }
    
    func makeAddCompanionsFuture(_ companions: [User], on conn: DatabaseConnectable) throws -> Future<Record.Intact> {
        return companions.map { companion in
            return self.companions.attach(companion, on: conn)
        }.flatMap(to: Record.Intact.self, on: conn) { _ in
            return try self.makeIntactFuture(on: conn)
        }
    }
    
    func makeRemoveAllCompanionsFuture(on conn: DatabaseConnectable) -> Future<Void> {
        return companions.detachAll(on: conn)
    }
    
    func makeAttachmentFuture(with file: File, on conn: DatabaseConnectable) throws -> Future<Attachment> {
        let name = UUID().uuidString
        try Current.resourcePersisting.save(file.data, name)
        
        return Attachment(name: name, recordID: try requireID()).save(on: conn)
    }
}
