// This type contains APIs related to users, and it should NOT be accessed directly

// TODO: Rename properties, for example: `getUser` to `getMe`
struct UsersWebService {
    var signUp = signUp(with:)
    var logIn = logIn(with:)
    var getUser = getUser(with:)
    var updateUser = updateUser(with:)
    var searchUsers = searchUsers(with:)
}

// MARK: - Private
private func signUp(with parameters: SignUpParameters) -> Future<Result<User, NetworkError>> {
    return parameters
        |> Request.makeSignUp(with:)
        >>> Current.urlSession().send(_:)
}

private func logIn(with parameters: LogInParameters) -> Future<Result<User, NetworkError>> {
    return parameters
        |> Request.makeBasicAuthenticated(with:)
        >>> Current.urlSession().send(_:)
}

private func getUser(with id: Int) -> Future<Result<User, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .user(id: id), method: .get)
}

private func updateUser(with parameters: UpdateUserParameters) -> Future<Result<User, NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatdRequest(to: .user(id: parameters.id), method: .put, parameters: parameters)
}

private func searchUsers(with key: String) -> Future<Result<[User], NetworkError>> {
    return Current.urlSession().sendTokenAuthenticatedRequest(to: .search(key: key), method: .get)
}

// MARK: - Helpers
private extension Request {
    static func makeSignUp(with parameters: SignUpParameters) -> Request {
        return Request(url: Endpoint.signUp.url, method: .post, bodyParameters: parameters, dateEncodingStrategy: nil, headers: nil, dateDecodingStrategy: nil)
    }
    
    static func makeBasicAuthenticated(with parameters: LogInParameters) -> Request {
        return Request(url: Endpoint.login.url, method: .post, headers: ["Authorization": "Basic \(parameters.makeBase64String())"], dateDecodingStrategy: nil)
    }
}
