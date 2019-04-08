import Vapor
import Crypto

final class UsersController: RouteCollection {
    func boot(router: Router) throws {
        let usersGroup = router.grouped("users")
        usersGroup.post(use: createHandler)
        
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardMiddleware = User.guardAuthMiddleware()
        let basicProtected = usersGroup.grouped(basicAuthMiddleware, guardMiddleware)
        basicProtected.post("login", use: loginHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = usersGroup.grouped(tokenAuthMiddleware, guardMiddleware)
        tokenProtected.get(User.parameter, use: getOneHandler)
        tokenProtected.put(User.parameter, use: updateHandler)
        tokenProtected.get(User.parameter, "records", use: getRecordsHandler)
    }
}

private extension UsersController {
    func getOneHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.parameters.next(User.self).makePublic()
    }
    
    func createHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).flatMap { user in
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req).makePublic()
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        // TODO: Use requesr body instead 
        return try flatMap(to: User.Public.self, req.parameters.next(User.self), req.content.decode(User.Public.self)) { user, updatedPublicUser in
            // NOT update `password` & `username`
            user.firstName = updatedPublicUser.firstName
            user.lastName = updatedPublicUser.lastName
            user.email = updatedPublicUser.email
            
            return user.save(on: req).makePublic()
        }
    }
    
    func getRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        return try req.parameters.next(User.self).flatMap(to: [Record].self) { user in
            return try user.records.query(on: req).all()
        }
    }
    
    // TODO: Return public user + token
    func loginHandler(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.make(for: user)
        return token.save(on: req)
    }
    
    // NOT expose this handler to router
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(User.self).delete(on: req).transform(to: .noContent)
    }
}
