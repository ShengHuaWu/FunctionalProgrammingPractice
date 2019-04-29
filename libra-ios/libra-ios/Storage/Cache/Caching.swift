import Foundation

func save<Key, Entity>(_ entity: Entity, as witness: Caching<Key, Entity>) throws where Key: Hashable  {
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

extension Caching where Key == String, Entity == String {
    // Use `userDefaults` for now, because there is no certificate for Apple developer
    static let token = Caching(persisting: .userDefaults, key: "co.libra-ios.token")
}
