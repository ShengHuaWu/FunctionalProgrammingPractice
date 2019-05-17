// Use this type to persist friends (people)
struct FriendsStorage {
    var save = { try saveEntity($0, as: .friends) }
    var fetch = { try fetchEntity(as: .friends) }
    var delete = { try deleteEntity(as: .friends) }
    var saveChangingActions = { try saveEntity($0, as: .friendChangingActions) }
    var fetchChangingActions = { try fetchEntity(as: .friendChangingActions) }
    var deleteChangingActions = { try deleteEntity(as: .friendChangingActions) }
}
