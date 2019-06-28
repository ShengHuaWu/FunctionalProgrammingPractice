import Vapor

final class CustomTokenAuthenticationMiddleware: Middleware {
    private let tokenAuthenticationMiddleware = User.tokenAuthMiddleware()
    
    func respond(to request: Request, chainingTo next: Responder) throws -> EventLoopFuture<Response> {
        let responder = BasicResponder { req in
            guard let token = try req.authenticated(Token.self), !token.isRevoked else {
                throw Abort(.unauthorized)
            }
            
            return try next.respond(to: req)
        }
        
        return try tokenAuthenticationMiddleware.respond(to: request, chainingTo: responder)
    }
}
