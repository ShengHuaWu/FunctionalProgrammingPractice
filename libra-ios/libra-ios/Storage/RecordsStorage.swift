// Use this type to persits records
struct RecordsStorage {
    var save = { try saveEntity($0, as: .records) }
    var fetch = { try fetchEntity(as: .records) }
    var delete = { try deleteEntity(as: .records) }
    var saveChangingActions = { try saveEntity($0, as: .recordChangingActions) }
    var fetchChangingActions = { try fetchEntity(as: .recordChangingActions) }
    var deleteChangingActions = { try deleteEntity(as: .recordChangingActions) }
}
