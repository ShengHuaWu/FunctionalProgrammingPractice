import Vapor

final class RecordsController: RouteCollection {
    func boot(router: Router) throws {
        let recordsGroup = router.grouped("records")
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardMiddleware = User.guardAuthMiddleware()
        let tokenProtected = recordsGroup.grouped(tokenAuthMiddleware, guardMiddleware)
        tokenProtected.get(use: getAllFromUserHandler)
        tokenProtected.get(Record.parameter, use: getOneHandler)
        tokenProtected.post(use: createHandler)
        tokenProtected.put(Record.parameter, use: updateHandler)
        tokenProtected.delete(Record.parameter, use: deleteHandler)
    }
}

private extension RecordsController {
    func getAllFromUserHandler(_ req: Request) throws -> Future<[Record.Intact]> {
        return try req.requireAuthenticated(User.self).makeAllRecordsFuture(on: req).makeIntacts(on: req)
    }
    
    func getOneHandler(_ req: Request) throws -> Future<Record.Intact> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Record.self).validate(creator: user).makeIntact(on: req)
    }
    
    func createHandler(_ req: Request) throws -> Future<Record.Intact> {
        let user = try req.requireAuthenticated(User.self)
        let bodyFuture = try req.content.decode(json: Record.RequestBody.self, using: .custom(dates: .millisecondsSince1970))
        let recordFuture = try bodyFuture.makeRecord(for: user).save(on: req)
        let companionsFuture = bodyFuture.makeQueuyCompanions(on: req)
        
        return flatMap(to: Record.Intact.self, recordFuture, companionsFuture) { record, companions in
            return try record.makeAddCompanionsFuture(companions, on: req)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Record.Intact> {
        let user = try req.requireAuthenticated(User.self)
        let recordFuture = try req.parameters.next(Record.self).validate(creator: user)
        let bodyFuture = try req.content.decode(json: Record.RequestBody.self, using: .custom(dates: .millisecondsSince1970))
        
        return flatMap(to: Record.Intact.self, recordFuture, bodyFuture) { record, body in
            let updateRecordFuture = record.update(with: body).save(on: req).makeRemoveAllCompanions(on: req)
            let companionsFuture = User.makeQueryFuture(using: body.companionIDs, on: req)
            
            return flatMap(to: Record.Intact.self, updateRecordFuture, companionsFuture) { _, companions in
                return try record.makeAddCompanionsFuture(companions, on: req)
            }
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Record.self).validate(creator: user).delete(on: req).transform(to: .noContent)
    }
}
