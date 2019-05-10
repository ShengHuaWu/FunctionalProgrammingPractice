// This type contains APIs related to records, and it should NOT be accessed directly

struct RecordsWebService {
    var getAll = getAllRecords
    var get = getRecord(with:)
    var create = createRecord(with:)
    var update = updateRecord(with:)
    var delete = deleteRecord(with:)
}

// MARK: - Private
private func getAllRecords() -> Future<Result<[Record], NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .records, method: .get)
}

private func getRecord(with id: Int) -> Future<Result<Record, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .record(id: id), method: .get)
}

private func createRecord(with parameters: RecordParameters) -> Future<Result<Record, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatdRequest(to: .records, method: .post, parameters: parameters)
}

private func updateRecord(with parameters: RecordParameters) -> Future<Result<Record, NetworkError>> {
    guard let id = parameters.id else {
        return Future { callback in
            callback(.failure(.badRequest))
        }
    }
    
    return Current.urlSession().sendTokenAuthenticatdRequest(to: .record(id: id), method: .put, parameters: parameters)
}

private func deleteRecord(with id: Int) -> Future<Result<SuccessResponse, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .record(id: id), method: .delete)
}
