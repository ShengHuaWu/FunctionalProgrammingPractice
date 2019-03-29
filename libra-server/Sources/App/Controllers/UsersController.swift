import Vapor
import Crypto

final class UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersGroup = router.grouped("users")
        usersGroup.get(User.parameter, use: getOneHandler)
        usersGroup.post(use: createHandler)
        usersGroup.put(User.parameter, use: updateHandler)
        usersGroup.get(User.parameter, "records", use: getRecordsHandler)
    }
}

private extension UsersController {
    func getOneHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).toPublic()
    }
    
    func createHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req).toPublic()
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        return try flatMap(to: User.Public.self, req.parameters.next(User.self), req.content.decode(User.Public.self)) { user, updatedPublicUser in
            // NOT update `password` & `username`
            user.firstName = updatedPublicUser.firstName
            user.lastName = updatedPublicUser.lastName
            user.email = updatedPublicUser.email
            
            return user.save(on: req).toPublic()
        }
    }
    
    func getRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        return try req.parameters.next(User.self).flatMap(to: [Record].self) { user in
            return try user.records.query(on: req).all()
        }
    }
    
    // NOT expose this handler to router
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).delete(on: req).transform(to: .noContent)
    }
}
