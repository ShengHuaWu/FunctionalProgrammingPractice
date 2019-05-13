// TODO: Separate into different files, for example, `UserStorage`, `RecordsStorage`, ...
struct Storage {
    var saveToken = { try save($0, as: .token) }
    var fetchToken = { try fetchEntity(as: .token) }
    var deleteToken = { try deleteEntity(as: .token) }
    var saveUser = { try save($0, as: .user) }
    var fetchUser = { try fetchEntity(as: .user) }
    var deleteUser = { try deleteEntity(as: .user) }
    var saveRecords = { try save($0, as: .records) }
    var fetchRecords = { try fetchEntity(as: .records) }
    var deleteRecords = { try deleteEntity(as: .records) }
    var saveFriends = { try save($0, as: .friends) }
    var fetchFriends = { try fetchEntity(as: .friends) }
    var deleteFriends = { try deleteEntity(as: .friends) }
}
