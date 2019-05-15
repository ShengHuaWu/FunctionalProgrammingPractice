import Foundation

enum PersistingError: Error {
    case noEntity
    case unexpectedEntityData
    case unhandledError(status: OSStatus)
}

struct Persisting<Key, Entity> where Key: Hashable {
    let save: (Entity, Key) throws -> Void
    let fetch: (Key) throws -> Entity
    let delete: (Key) throws -> Void
}

extension Persisting where Key == String, Entity == String {
    static let keychain = Persisting(
        save: save(_:toKeychainFor:),
        fetch: fetchStringFromKeychain,
        delete: deleteStringInKeychain)
    
    static let userDefaults = Persisting(
        save: save(_:toUserDefaultsFor:),
        fetch: fetchStringFromUserDefaults,
        delete: deleteEntityInUserDefaults)
}

extension Persisting where Key == String, Entity: Codable {
    // Cannot use `static let` because it doesn't support generic type `Entity: Codable`
    static var userDefaults: Persisting {
        return Persisting(
        save: save(_:toUserDefaultsFor:),
        fetch: fetchEntityFromUserDefaults,
        delete: deleteEntityInUserDefaults)
    }
}

// MARK: - Keychain
private func save(_ string: String, toKeychainFor key: String) throws {
    let encodedEntity = string.data(using: String.Encoding.utf8)!
    
    do {
        // Check for an existing item in the keychain.
        try _ = fetchStringFromKeychain(for: key)
        
        // Update the existing item with the new entity.
        var attributesToUpdate = [String : AnyObject]()
        attributesToUpdate[kSecValueData as String] = encodedEntity as AnyObject?
        
        let query = makeKeychainQuery(with: key)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        guard status == noErr else { throw PersistingError.unhandledError(status: status) }
    } catch PersistingError.noEntity {
        // No entity was found in the keychain. Create a dictionary to save as a new keychain item.
        var query = makeKeychainQuery(with: key)
        query[kSecValueData as String] = encodedEntity as AnyObject?
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == noErr else { throw PersistingError.unhandledError(status: status) }
    }
}

private func fetchStringFromKeychain(for key: String) throws -> String {
    var query = makeKeychainQuery(with: key)
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    query[kSecReturnAttributes as String] = kCFBooleanTrue
    query[kSecReturnData as String] = kCFBooleanTrue
    
    // Try to fetch the existing keychain item that matches the query.
    var queryResult: AnyObject?
    let status = withUnsafeMutablePointer(to: &queryResult) { value in
        SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(value))
    }
    
    guard status != errSecItemNotFound else { throw PersistingError.noEntity }
    guard status == noErr else { throw PersistingError.unhandledError(status: status) }
    
    guard let existingItem = queryResult as? [String : AnyObject],
        let data = existingItem[kSecValueData as String] as? Data,
        let entity = String(data: data, encoding: String.Encoding.utf8) else {
            throw PersistingError.unexpectedEntityData
    }
    
    return entity
}

private func deleteStringInKeychain(for key: String) throws {
    let query = makeKeychainQuery(with: key)
    let status = SecItemDelete(query as CFDictionary)
    
    guard status == noErr || status == errSecItemNotFound else { throw PersistingError.unhandledError(status: status) }
}

private func makeKeychainQuery(with key: String) -> [String: AnyObject] {
    var query = [String : AnyObject]()
    query[kSecClass as String] = kSecClassGenericPassword
    query[kSecAttrService as String] = "co.libra-ios" as AnyObject?
    query[kSecAttrAccount as String] = key as AnyObject?
    query[kSecAttrAccessGroup as String] = "co.libra-ios" as AnyObject?
    
    return query
}

// MARK: - User Defaults
private func save(_ string: String, toUserDefaultsFor key: String) throws {
    UserDefaults.standard.set(string, forKey: key)
}

private func fetchStringFromUserDefaults(for key: String) throws -> String {
    guard let result = UserDefaults.standard.string(forKey: key) else { throw PersistingError.noEntity }
    
    return result
}

private func deleteEntityInUserDefaults(for key: String) throws {
    UserDefaults.standard.removeObject(forKey: key)
}

private func save<Entity>(_ entity: Entity, toUserDefaultsFor key: String) throws where Entity: Encodable {
    do {
        let data = try PropertyListEncoder().encode(entity)
        UserDefaults.standard.set(data, forKey: key)
    } catch {
        throw PersistingError.unexpectedEntityData
    }
}

private func fetchEntityFromUserDefaults<Entity>(for key: String) throws -> Entity where Entity: Decodable {
    guard let data = UserDefaults.standard.data(forKey: key) else { throw PersistingError.noEntity }
    
    do {
        return try PropertyListDecoder().decode(Entity.self, from: data)
    } catch {
        throw PersistingError.unexpectedEntityData
    }
}
