import Foundation

enum CacheError: Error {
    case noEntity
    case unexpectedEntityData
    case unhandledError(status: OSStatus)
}

struct Cache {
    let saveToken = { try save($0, as: .token) }
    let fetchToken = { try fetchEntity(as: .token) }
    let deleteToken = { try deleteEntity(as: .token) }
}

private func save<Key, Entity>(_ entity: Entity, as witness: Caching<Key, Entity>) throws where Key: Hashable  {
    try witness.save(entity, witness.key)
}

private func fetchEntity<Key, Entity>(as witness: Caching<Key, Entity>) throws -> Entity where Key: Hashable {
    return try witness.fetch(witness.key)
}

private func deleteEntity<Key, Entity>(as witness: Caching<Key, Entity>) throws where Key: Hashable {
    try witness.delete(witness.key)
}

private struct Caching<Key, Entity> where Key: Hashable {
    let save: (Entity, Key) throws -> Void
    let fetch: (Key) throws -> Entity
    let delete: (Key) throws -> Void
    let key: Key
}

extension Caching where Key == String, Entity == String {
    static let token = Caching(
        save: save(_:toKeychainFor:),
        fetch: fetchEntityToKeychain(for:),
        delete: deleteEntityToKeychain(for:),
        key: "co.libra-ios.token")
}

// TODO: Refactor these three functions
private func save(_ entity: String, toKeychainFor key: String) throws {
    let encodedEntity = entity.data(using: String.Encoding.utf8)!
    
    do {
        // Check for an existing item in the keychain.
        try _ = fetchEntityToKeychain(for: key)
        
        // Update the existing item with the new entity.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecValueData as String] = encodedEntity as AnyObject?
        
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = "co.libra-ios" as AnyObject?
        query[kSecAttrAccount as String] = key as AnyObject?
        query[kSecAttrAccessGroup as String] = "co.libra-ios" as AnyObject?
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        guard status == noErr else { throw CacheError.unhandledError(status: status) }
    } catch CacheError.noEntity {
        // No entity was found in the keychain. Create a dictionary to save as a new keychain item.
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = "co.libra-ios" as AnyObject?
        query[kSecAttrAccount as String] = key as AnyObject?
        query[kSecAttrAccessGroup as String] = "co.libra-ios" as AnyObject?
        query[kSecValueData as String] = encodedEntity as AnyObject?
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == noErr else { throw CacheError.unhandledError(status: status) }
    }
}

private func fetchEntityToKeychain(for key: String) throws -> String {
    var query = [String : AnyObject]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrService as String] = "co.libra-ios" as AnyObject?
    query[kSecAttrAccount as String] = key as AnyObject?
    query[kSecAttrAccessGroup as String] = "co.libra-ios" as AnyObject?
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    query[kSecReturnData as String] = kCFBooleanTrue
    
    // Try to fetch the existing keychain item that matches the query.
    var queryResult: AnyObject?
    let status = withUnsafeMutablePointer(to: &queryResult) {
        SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    guard status != errSecItemNotFound else { throw CacheError.noEntity }
    guard status == noErr else { throw CacheError.unhandledError(status: status) }
    
    guard let existingItem = queryResult as? [String : AnyObject],
        let data = existingItem[kSecValueData as String] as? Data,
        let entity = String(data: data, encoding: String.Encoding.utf8) else {
            throw CacheError.unexpectedEntityData
    }
    
    return entity
}

private func deleteEntityToKeychain(for key: String) throws {
    var query = [String : AnyObject]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrService as String] = "co.libra-ios" as AnyObject?
    query[kSecAttrAccount as String] = key as AnyObject?
    query[kSecAttrAccessGroup as String] = "co.libra-ios" as AnyObject?
    let status = SecItemDelete(query as CFDictionary)
    
    guard status == noErr || status == errSecItemNotFound else { throw CacheError.unhandledError(status: status) }
}
