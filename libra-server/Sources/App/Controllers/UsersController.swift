import Vapor
import Crypto

final class UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersGroup = router.grouped("users")
        usersGroup.get(User.parameter, use: getOneHandler)
        usersGroup.post(use: createHandler)
        usersGroup.put(User.parameter, use: updateHandler)
    }
}

private extension UsersController {
    // TODO: Should return a public `User` type
    func getOneHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { user in
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<User> {
        return try flatMap(to: User.self, req.parameters.next(User.self), req.content.decode(User.self)) { user, updatedUser in
            user.firstName = updatedUser.firstName
            user.lastName = updatedUser.lastName
            user.email = updatedUser.email
            
            // TODO: Should NOT be able to update `password` and `username`
            user.password = updatedUser.password
            user.username = updatedUser.username
            
            return user.save(on: req)
        }
    }
}
