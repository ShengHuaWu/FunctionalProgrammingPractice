// TODO: Separate this file into different files

import Vapor

// MARK: - User Helpers
func authorize(_ authenticatedUser: User, hasAccessTo user: User) throws -> User {
    guard authenticatedUser.id == user.id else {
        throw Abort(.unauthorized)
    }
    
    return user
}
