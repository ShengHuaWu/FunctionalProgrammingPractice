import Vapor

final class RecordsController: RouteCollection {
    func boot(router: Router) throws {
        let recordsGroup = router.grouped("records")
        recordsGroup.get(Record.parameter, use: getOneHandler)
        recordsGroup.post(use: createHandler)
        recordsGroup.put(Record.parameter, use: updateHandler)
        recordsGroup.delete(Record.parameter, use: deleteHandler)
    }
}

private extension RecordsController {
    // NOT expose this handler to router
    func getAllHandler(_ req: Request) throws -> Future<[Record]> {
        return Record.query(on: req).decode(Record.self).all()
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Record.Intact> {
        return try req.parameters.next(Record.self).makeIntact(on: req)
    }
    
    func createHandler(_ req: Request) throws -> Future<Record.Intact> {
        let bodyFuture = try req.content.decode(json: Record.RequestBody.self, using: .custom(dates: .millisecondsSince1970))
        let recordFuture = bodyFuture.makeRecord().save(on: req)
        let companionsFuture = bodyFuture.makeQueuyCompanions(on: req)
        
        return flatMap(to: Record.Intact.self, recordFuture, companionsFuture) { record, companions in
            return try record.makeAttachCompanionsFuture(companions, on: req)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Record.Intact> {
        let recordFuture = try req.parameters.next(Record.self)
        let bodyFuture = try req.content.decode(json: Record.RequestBody.self, using: .custom(dates: .millisecondsSince1970))
        
        return flatMap(to: Record.Intact.self, recordFuture, bodyFuture) { record, body in
            let updateRecordFuture = record.update(with: body).save(on: req).makeDetachAllCompanions(on: req)
            let companionsFuture = User.makeQueryFuture(using: body.companionIDs, on: req)
            
            return flatMap(to: Record.Intact.self, updateRecordFuture, companionsFuture) { _, companions in
                return try record.makeAttachCompanionsFuture(companions, on: req)
            }
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Record.self).delete(on: req).transform(to: .noContent)
    }
}
