import Vapor

extension File {
    // TODO: Remove the resource if saving model fails
    func makeAttachmentFuture(for record: Record, on conn: DatabaseConnectable) throws -> Future<Attachment> {
        let name = UUID().uuidString
        try Current.resourcePersisting.save(data, name)
        
        return Attachment(name: name, recordID: try record.requireID()).save(on: conn)
    }
    
    func makeAvatarFuture(for user: User, on conn: DatabaseConnectable) throws -> Future<Avatar> {
        let name = UUID().uuidString
        try Current.resourcePersisting.save(data, name)
        
        return Avatar(name: name, userID: try user.requireID()).save(on: conn)
    }
}
