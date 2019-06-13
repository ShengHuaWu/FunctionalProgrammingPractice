import Vapor
import Crypto

final class UsersController: RouteCollection {
    func boot(router: Router) throws {
        // Not protected: signup
        // TODO: API key?
        let usersGroup = router.grouped("users")
        usersGroup.post("signup", use: signupHandler)
        
        // Basic protected: login
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardMiddleware = User.guardAuthMiddleware()
        let basicProtected = usersGroup.grouped(basicAuthMiddleware, guardMiddleware)
        basicProtected.post("login", use: loginHandler)
        
        // Token protected: get user, update user, search and friends group
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenProtected = usersGroup.grouped(tokenAuthMiddleware, guardMiddleware)
        tokenProtected.get(User.parameter, use: getOneHandler)
        tokenProtected.put(User.parameter, use: updateHandler)
        
        let searchGroup = tokenProtected.grouped("search")
        searchGroup.get(use: searchHandler)
        
        let friendsGroup = tokenProtected.grouped(User.parameter, "friends")
        friendsGroup.get(use: getAllFriendsHandler)
        friendsGroup.get(User.parameter, use: getOneFriendHandler)
        friendsGroup.post(use: addFriendHandler)
        friendsGroup.delete(User.parameter, use: removeFriendHandler)
    }
}

private extension UsersController {
    func getOneHandler(_ req: Request) throws -> Future<User.Public> {
        let authedUser = try req.requireAuthenticated(User.self)
        
        return try req.parameters.next(User.self).isAuthorized(by: authedUser).makePublic()
    }
    
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userParametersFuture = try req.parameters.next(User.self).isAuthorized(by: authedUser)
        
        return try flatMap(to: User.Public.self, userParametersFuture, req.content.decode(User.UpdateRequestBody.self)) { user, body in
            return user.update(with: body).save(on: req).makePublic()
        }
    }
    
    func signupHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(User.self).encryptPassword().save(on: req).flatMap(to: User.Public.self) { user in
            return try user.makeTokenFuture(on: req).save(on: req).makePublicUser(for: user)
        }
    }
    
    func loginHandler(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        
        return try user.makeTokenFuture(on: req).save(on: req).makePublicUser(for: user)
    }
    
    // TODO: Logout handler?

    func searchHandler(_ req: Request) throws -> Future<[User.Public]> {
        let key = try req.query.get(String.self, at: "q")

        // Wildcards: https://www.tutorialspoint.com/postgresql/postgresql_like_clause.htm
        return User.makeSearchQueryFuture(using: "%\(key)%", on: req).makePublics()
    }
    
    func getAllFriendsHandler(_ req: Request) throws -> Future<[User.Public]> {
        let authedUser = try req.requireAuthenticated(User.self)
        
        return try req.parameters.next(User.self).isAuthorized(by: authedUser).makeAllFriends(on: req).makePublics()
    }
    
    func getOneFriendHandler(_ req: Request) throws -> Future<User.Public> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userParametersFuture = try req.parameters.next(User.self).isAuthorized(by: authedUser)
        let personParametersFuture = try req.parameters.next(User.self)
        
        return flatMap(to: User.Public.self, userParametersFuture, personParametersFuture) { user, person in
            return user.makeHasFriendshipFuture(with: person, on: req).map(to: User.Public.self) { isFriend in
                guard isFriend else { throw Abort(.notFound) }
                
                return person.makePublic()
            }
        }
    }
    
    func addFriendHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userParametersFuture = try req.parameters.next(User.self).isAuthorized(by: authedUser)
        let queryPersonFuture = try req.content.decode(AddFriendBody.self).flatMap(to: User?.self) { body in
            return User.makeSingleQueryFuture(using: body.personID, on: req)
        }
        
        return flatMap(to: HTTPStatus.self, userParametersFuture, queryPersonFuture) { user, person in
            guard let unwrappedPerson = person else { throw Abort(.badRequest) }
            
            return user.makeHasFriendshipFuture(with: unwrappedPerson, on: req).flatMap(to: HTTPStatus.self) { isFriend in
                guard isFriend else { return user.makeAddFriendshipFuture(to: unwrappedPerson, on: req) }
                
                return Future.done(on: req).transform(to: .created)
            }
        }
    }
    
    func removeFriendHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userParametersFuture = try req.parameters.next(User.self).isAuthorized(by: authedUser)
        let personParametersFuture = try req.parameters.next(User.self)
        
        return flatMap(to: HTTPStatus.self, userParametersFuture, personParametersFuture) { user, person in
            return user.makeHasFriendshipFuture(with: person, on: req).flatMap(to: HTTPStatus.self) { isFriend in
                guard isFriend else { return Future.done(on: req).transform(to: .noContent) }
                
                return user.makeRemoveFriendshipFuture(to: person, on: req)
            }
        }
    }
    
    // TODO: Upload & download avatar
}
