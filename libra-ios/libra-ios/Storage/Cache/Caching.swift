import Foundation

func saveEntity<Key, Entity>(_ entity: Entity, as witness: Caching<Key, Entity>) throws where Key: Hashable  {
    try witness.persisting.save(entity, witness.key)
}

func fetchEntity<Key, Entity>(as witness: Caching<Key, Entity>) throws -> Entity where Key: Hashable {
    return try witness.persisting.fetch(witness.key)
}

func deleteEntity<Key, Entity>(as witness: Caching<Key, Entity>) throws where Key: Hashable {
    try witness.persisting.delete(witness.key)
}


struct Caching<Key, Entity> where Key: Hashable {
    let persisting: Persisting<Key, Entity>
    let key: Key
}

// Use `userDefaults` to cache token for now, because there is no certificate for Apple developer
extension Caching where Key == String, Entity == String {
    static let token = Caching(persisting: .userDefaults, key: "co.libra-ios.token")
}

extension Caching where Key == String, Entity == User {
    static let user = Caching(persisting: .userDefaults, key: "co.libra-ios.user")
}

extension Caching where Key == String, Entity == [Record] {
    static let records = Caching(persisting: .userDefaults, key: "co.libra.ios.records")
}

extension Caching where Key == String, Entity == [Person] {
    static let friends = Caching(persisting: .userDefaults, key: "co.libra.ios.friends")
}
