// Use this type to persist user
struct UserStorage {
    var save = { try saveEntity($0, as: .user) }
    var fetch = { try fetchEntity(as: .user) }
    var delete = { try deleteEntity(as: .user) }
    // TODO: Save, fetch, and delete changing actions (the same for records & friends)
}
