import Vapor

final class RecordsController: RouteCollection {
    func boot(router: Router) throws {
        let recordsGroup = router.grouped("records")
        recordsGroup.get(use: getAllHandler)
        recordsGroup.get(Record.parameter, use: getOneHandler)
        recordsGroup.post(use: createHandler)
        recordsGroup.put(Record.parameter, use: updateHandler)
        recordsGroup.delete(Record.parameter, use: deleteHandler)
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
            
            return record.save(on: req)
        }
    }
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Record.self).flatMap { record in
            return record.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
}
