// This type contains APIs related to users, and it should NOT be accessed directly

struct UsersWebService {
    var get = getUser(with:)
    var update = updateUser(with:)
    var search = searchUsers(with:)
}

// MARK: - Private
private func getUser(with id: Int) -> Future<Result<User, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .user(id: id), method: .get)
}

private func updateUser(with parameters: UpdateUserParameters) -> Future<Result<User, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatdRequest(to: .user(id: parameters.id), method: .put, parameters: parameters)
}

private func searchUsers(with key: String) -> Future<Result<[Person], NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .search(key: key), method: .get)
}
