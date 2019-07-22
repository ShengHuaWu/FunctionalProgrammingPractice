import Vapor
import Crypto

final class UsersController: RouteCollection {
    func boot(router: Router) throws {
        // Not protected
        // TODO: Authentication emails and SMS
        let usersGroup = router.grouped("users")
        usersGroup.post("signup", use: signupHandler)
        
        // Basic protected
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let guardMiddleware = User.guardAuthMiddleware()
        let basicProtected = usersGroup.grouped(basicAuthMiddleware, guardMiddleware)
        basicProtected.post("login", use: loginHandler)
        
        // Token protected
        let tokenAuthMiddleware = User.customTokenAuthMiddleware()
        let tokenProtected = usersGroup.grouped(tokenAuthMiddleware, guardMiddleware)
        tokenProtected.delete("logout", use: logoutHandler)
        tokenProtected.get("search", use: searchHandler)

        tokenProtected.get(User.parameter, use: getOneHandler)
        tokenProtected.put(User.parameter, use: updateHandler)
        
        let friendsGroup = tokenProtected.grouped(User.parameter, "friends")
        friendsGroup.get(use: getAllFriendsHandler)
        friendsGroup.get(User.parameter, use: getOneFriendHandler)
        friendsGroup.post(use: addFriendHandler)
        friendsGroup.delete(User.parameter, use: removeFriendHandler)
        
        let avatarsGroup = tokenProtected.grouped(User.parameter, "avatars")
        avatarsGroup.post(use: uploadAvatarHandler)
        avatarsGroup.get(Avatar.parameter, use: downloadAvatarHandler)
        avatarsGroup.delete(Avatar.parameter, use: deleteAvatarHandler)
    }
}

private extension UsersController {
    func getOneHandler(_ req: Request) throws -> Future<User.Public> {
        let authedUser = try req.requireAuthenticated(User.self)
        
        return try req.parameters.next(User.self)
            .map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
            .flatMap { try convert($0, toPublicOn: req) }
    }
    
    func updateHandler(_ req: Request) throws -> Future<User.Public> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userFuture = try req.parameters.next(User.self).map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
        
        return try flatMap(to: User.Public.self, userFuture, req.content.decode(User.UpdateRequestBody.self)) { user, body in
            return user.update(with: body).save(on: req).flatMap { try convert($0, toPublicOn: req) }
        }
    }
    
    func signupHandler(_ req: Request) throws -> Future<User.Public> {
        return try req.content.decode(AuthenticationBody.self).flatMap { try signUp(with: $0, on: req) }
    }
    
    func loginHandler(_ req: Request) throws -> Future<User.Public> {
        let user = try req.requireAuthenticated(User.self)
        
        return try req.content.decode(AuthenticationBody.self).flatMap { try logIn(for: user, with: $0, on: req) }
    }
    
    func logoutHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let user = try req.requireAuthenticated(User.self)
        let bodyFuture = try req.content.decode(AuthenticationBody.self)
        
        return bodyFuture
            .flatMap(to: Token?.self) { body in
                return try queryToken(of: user, with: body, on: req)
            }
            .flatMap(to: HTTPStatus.self) { token in
                guard let unwrappedToken = token else {
                    throw Abort(.internalServerError)
                }
                
                return revoke(unwrappedToken, on: req)
        }
    }

    func searchHandler(_ req: Request) throws -> Future<[User.Public]> {
        let key = try req.query.get(String.self, at: "q")

        // Wildcards: https://www.tutorialspoint.com/postgresql/postgresql_like_clause.htm
        return searchUsers(with: "%\(key)%", on: req).flatMap { try convert($0, toPublicsOn: req) }
    }
    
    func getAllFriendsHandler(_ req: Request) throws -> Future<[User.Public]> {
        let authedUser = try req.requireAuthenticated(User.self)
        
        return try req.parameters.next(User.self)
            .map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
            .flatMap { try queryAllFriends(of: $0, on: req) }
            .flatMap { try convert($0, toPublicsOn: req) }
    }
    
    func getOneFriendHandler(_ req: Request) throws -> Future<User.Public> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userFuture = try req.parameters.next(User.self).map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
        let personFuture = try req.parameters.next(User.self)
        
        return flatMap(to: User.Public.self, userFuture, personFuture) { user, person in
            return check(user, hasFriendshipWith: person, on: req)
                .flatMap(to: User.Public.self) { isFriend in
                guard isFriend else { throw Abort(.notFound) }
                
                return try convert(person, toPublicOn: req)
            }
        }
    }
    
    func addFriendHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userFuture = try req.parameters.next(User.self).map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
        let queryPersonFuture = try req.content.decode(AddFriendBody.self).flatMap(to: User?.self) { body in
            return queryFriend(with: body.personID, on: req)
        }
        
        return flatMap(to: HTTPStatus.self, userFuture, queryPersonFuture) { user, person in
            guard let unwrappedPerson = person else { throw Abort(.badRequest) }
            
            return check(user, hasFriendshipWith: unwrappedPerson, on: req)
                .flatMap(to: HTTPStatus.self) { isFriend in
                guard isFriend else { return addFriendship(between: user, and: unwrappedPerson, on: req) }
                
                return Future.done(on: req).transform(to: .created)
            }
        }
    }
    
    func removeFriendHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userFuture = try req.parameters.next(User.self).map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
        let personFuture = try req.parameters.next(User.self)
        
        return flatMap(to: HTTPStatus.self, userFuture, personFuture) { user, person in
            return check(user, hasFriendshipWith: person, on: req)
                .flatMap(to: HTTPStatus.self) { isFriend in
                guard isFriend else { return Future.done(on: req).transform(to: .noContent) }
                
                return removeFriendship(between: user, and: person, on: req)
            }
        }
    }
    
    func uploadAvatarHandler(_ req: Request) throws -> Future<Asset> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userFuture = try req.parameters.next(User.self).map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
        let fileFuture = try req.content.decode(File.self) // There is a limitation of request size (1 MB by default)
        
        return flatMap(to: Asset.self, userFuture, fileFuture) { user, file in
            return try createNewAvatar(of: user, with: file, on: req).map(Asset.init)
        }
    }
    
    func downloadAvatarHandler(_ req: Request) throws -> Future<HTTPResponse> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userFuture = try req.parameters.next(User.self).map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
        
        return try map(to: Avatar.self, req.parameters.next(Avatar.self), userFuture, check(_:belongsTo:)).map(HTTPResponse.init)
    }
    
    func deleteAvatarHandler(_ req: Request) throws -> Future<HTTPStatus> {
        let authedUser = try req.requireAuthenticated(User.self)
        let userFuture = try req.parameters.next(User.self).map { try authorize(authedUser, toAccess: $0, as: .authenticated) }
        
        return try map(to: Avatar.self, req.parameters.next(Avatar.self), userFuture, check(_:belongsTo:))
            .map(deleteFile)
            .delete(on: req)
            .transform(to: .noContent)
    }
}
