// This type contains APIs related to records, and it should NOT be accessed directly
struct RecordsWebService {
    var getRecords = getAllRecords
    var getRecord = getRecord(with:)
    var createRecord = createRecord(with:)
    var updateRecord = updateRecord(with:)
    var deleteRecord = deleteRecord(with:)
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
