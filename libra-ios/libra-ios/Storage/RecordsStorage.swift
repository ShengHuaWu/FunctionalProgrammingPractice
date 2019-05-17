// Use this type to persits records
struct RecordsStorage {
    var save = { try saveEntity($0, as: .records) }
    var fetch = { try fetchEntity(as: .records) }
    var delete = { try deleteEntity(as: .records) }
    // TODO: Save, fetch, and delete changing actions (the same for friends)
}
