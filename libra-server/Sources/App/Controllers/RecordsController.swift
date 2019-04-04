import Vapor
import FluentPostgreSQL

final class RecordsController: RouteCollection {
    func boot(router: Router) throws {
        let recordsGroup = router.grouped("records")
        recordsGroup.get(Record.parameter, use: getOneHandler)
        recordsGroup.post(use: createHandler)
        recordsGroup.put(Record.parameter, use: updateHandler)
        recordsGroup.delete(Record.parameter, use: deleteHandler)
        recordsGroup.post(Record.parameter, "companions", User.parameter, use: addCompanionsHandler)
    }
}

private extension RecordsController {
    // NOT expose this handler to router
    func getAllHandler(_ req: Request) throws -> Future<[Record]> {
        return Record.query(on: req).decode(Record.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Record.Intact> {
        return try req.parameters.next(Record.self).toIntact(on: req)
    }
    
    func createHandler(_ req: Request) throws -> Future<Record.Intact> {
        let creationBodyFuture = try req.content.decode(json: Record.CreationBody.self, using: .custom(dates: .millisecondsSince1970))
        let recordFuture = try creationBodyFuture.toRecord().save(on: req)
        let companionsFuture = creationBodyFuture.flatMap(to: [User].self) { creation in
            return User.query(on: req).decode(User.self).filter(.make(\User.id, .in, creation.companionIDs)).all()
        }
        
        return flatMap(to: Record.Intact.self, recordFuture, companionsFuture) { record, companions in
            return companions.map { companion in
                return record.companions.attach(companion, on: req)
            }.flatMap(to: Record.Intact.self, on: req) { _ in
                return try record.toIntactFuture(on: req)
            }
        }
    }
    
    // TODO: Update companions & return Record.Intact
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
    
    func addCompanionsHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Record.self), req.parameters.next(User.self)) { record, user in
            return record.companions.attach(user, on: req).transform(to: .created)
        }
    }
}
