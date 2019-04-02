import Vapor

final class RecordsController: RouteCollection {
    func boot(router: Router) throws {
        let recordsGroup = router.grouped("records")
        recordsGroup.get(use: getAllHandler)
        recordsGroup.get(Record.parameter, use: getOneHandler)
        recordsGroup.post(use: createHandler)
        recordsGroup.put(Record.parameter, use: updateHandler)
        recordsGroup.delete(Record.parameter, use: deleteHandler)
        recordsGroup.get(Record.parameter, "creator", use: getCreatorHandler)
        
        // TODO: To be removed
        recordsGroup.post(Record.parameter, "companions", User.parameter, use: addCompanionsHandler)
        recordsGroup.get(Record.parameter, "companions", use: getCompanionsHandler)
    }
}

private extension RecordsController {
    func getAllHandler(_ req: Request) throws -> Future<[Record]> {
        return Record.query(on: req).decode(Record.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Record> {
        return try req.parameters.next(Record.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<Record> {
        return try req.content.decode(json: Record.self, using: .custom(dates: .millisecondsSince1970)).save(on: req)
    }
    
    func updateHandler(_ req: Request) throws -> Future<Record> {
        return try flatMap(to: Record.self,
                           req.parameters.next(Record.self),
                           req.content.decode(json: Record.self, using: .custom(dates: .millisecondsSince1970))) { (record, updatedRecord) in
            record.title = updatedRecord.title
            record.note = updatedRecord.note
            record.date = updatedRecord.date
            record.amount = updatedRecord.amount
            record.currency = updatedRecord.currency
            record.mood = updatedRecord.mood
            record.creatorID = updatedRecord.creatorID
            
            return record.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Record.self).delete(on: req).transform(to: .noContent)
    }
    
    func getCreatorHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(Record.self).flatMap(to: User.Public.self) { record in
            return record.creator.get(on: req).toPublic()
        }
    }
    
    // TODO: Attach companions during `Record` creation
    func addCompanionsHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Record.self), req.parameters.next(User.self)) { record, user in
            return record.companions.attach(user, on: req).transform(to: .created)
        }
    }
    
    // TODO: Append companions with getting `Record`(s)
    func getCompanionsHandler(_ req: Request) throws -> Future<[User.Public]> {
        return try req.parameters.next(Record.self).flatMap { record in
            return try record.companions.query(on: req).all()
        }.map { users in
            return users.map { $0.toPublic() }
        }
    }
}
