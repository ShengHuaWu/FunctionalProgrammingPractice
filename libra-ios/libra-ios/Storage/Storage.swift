struct Storage {
    var saveToken = { try save($0, as: .token) }
    var fetchToken = { try fetchEntity(as: .token) }
    var deleteToken = { try deleteEntity(as: .token) }
    // TODO: Local storage
}
