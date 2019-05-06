import Vapor
import Crypto

final class UsersController: RouteCollection {
    func boot(router: Router) throws {
        // Not protected: signup
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
        
        return try req.parameters.next(User.self).validate(authedUser: authedUser).makePublic()
    }
    
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userParametersFuture = try req.parameters.next(User.self).validate(authedUser: authedUser)
        
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

    func searchHandler(_ req: Request) throws -> Future<[User.Public]> {
        let key = try req.query.get(String.self, at: "search")
        
        // TODO: Create a function ([User]) -> [User.Public]
        // TODO: Improve filters
        return User.query(on: req).group(.or) { orGroup in
            orGroup.filter(.make(\.firstName, .like, [key]))
            orGroup.filter(.make(\.lastName, .like, [key]))
            orGroup.filter(.make(\.email, .like, [key]))
        }.all().map { $0.map { $0.makePublic() } }
    }
    
    // TODO: Verify authenticated user and user parameter
    func getAllFriendsHandler(_ req: Request) throws -> Future<[User.Public]> {
        let user = try req.requireAuthenticated(User.self)
        
        // TODO: Create a function ([User]) -> [User.Public]
        return try user.friends.query(on: req).all().map { $0.map { $0.makePublic() } }
    }
    
    func getOneFriendHandler(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        _ = try req.parameters.next(User.self) // TODO: Use this for verify authenticated user
        
        // TODO: Rewrite this return statement as a method
        return try req.parameters.next(User.self).flatMap(to: User.Public.self) { friend in
            return user.friends.isAttached(friend, on: req).map(to: User.Public.self) { isFriend in
                guard isFriend else {
                    throw Abort(.notFound)
                }
                
                return friend.makePublic()
            }
        }
    }
    
    func addFriendHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        
        // TODO: Move it to other file
        struct AddFriendBody: Decodable {
            let friendID: User.ID
        }
        
        // TODO: Rewrite this return statement as a method
        // TODO: Use `isAttached`
        return try req.content.decode(AddFriendBody.self).flatMap(to: HTTPStatus.self) { body in
            return try user.friends.query(on: req).filter(.make(\User.id, .in, [body.friendID])).first().flatMap(to: HTTPStatus.self) { result in
                if result == nil {
                    return User.query(on: req).filter(.make(\.id, .in, [body.friendID])).first().flatMap(to: HTTPStatus.self) { friend in
                        guard let unwrappedFriend = friend else {
                            throw Abort(.badRequest)
                        }
                        
                        return user.friends.attachSameType(unwrappedFriend, on: req).transform(to: .created)
                    }
                } else {
                    throw Abort(.created)
                }
            }
        }
    }
    
    func removeFriendHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        _ = try req.parameters.next(User.self) // TODO: Use this for verify authenticated user
        
        // TODO: Rewrite this return statement as a method
        // TODO: Use `isAttached`
        return try req.parameters.next(User.self).flatMap(to: User?.self) { friend in
            return try user.friends.query(on: req).filter(.make(\User.id, .in, [friend.requireID()])).first()
        }.flatMap(to: HTTPStatus.self) { result in
            guard let unwrappedResult = result else {
                throw Abort(.noContent)
            }
            
            return user.friends.detach(unwrappedResult, on: req).transform(to: .noContent)
        }
    }
}
