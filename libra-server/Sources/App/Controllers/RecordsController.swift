import Vapor

final class RecordsController: RouteCollection {
    func boot(router: Router) throws {
        let recordGroup = router.grouped("records")
        recordGroup.get(use: getAllHandler)
        recordGroup.get(Record.parameter, use: getOneHandler)
        recordGroup.post(use: createHandler)
        recordGroup.put(Record.parameter, use: updateHandler)
        recordGroup.delete(Record.parameter, use: deleteHandler)
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
        return try req.content.decode(Record.self).flatMap { (Record) in
            return Record.save(on: req)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Record> {
        return try flatMap(to: Record.self, req.parameters.next(Record.self), req.content.decode(Record.self)) { (record, _) in
            // TODO: Update old record
            return record.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Record.self).flatMap { (Record) in
            return Record.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
}
