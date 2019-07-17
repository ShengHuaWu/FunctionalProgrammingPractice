import Vapor

func authorize<Resource>(_ user: User, toAccess resource: Resource, as witness: Accessing<Resource>) throws -> Resource {
    return try witness.access(user, resource)
}

struct Accessing<Resource> {
    let access: (User, Resource) throws -> Resource
}

extension Accessing where Resource == User {
    static let authenticated = Accessing { user, resouce in
        guard user.id == resouce.id else {
            throw Abort(.unauthorized)
        }
        
        return resouce
    }
}

extension Accessing where Resource == Record {
    static let creator = Accessing { user, resource in
        // Check `creatorID` as well as `isDeleted`
        guard try user.requireID() == resource.creatorID else {
            throw Abort(.unauthorized)
        }
        
        guard !resource.isDeleted else {
            throw Abort(.notFound)
        }
        
        return resource
    }
}
