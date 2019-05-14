struct RecordsStorage {
    var save = { try saveEntity($0, as: .records) }
    var fetch = { try fetchEntity(as: .records) }
    var delete = { try deleteEntity(as: .records) }
}
