// Use this type to persist token
struct AuthenticationStorage {
    var saveToken = { try saveEntity($0, as: .token) }
    var fetchToken = { try fetchEntity(as: .token) }
    var deleteToken = { try deleteEntity(as: .token) }
}
