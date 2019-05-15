// This type contains APIs related to authentication, and it should NOT be accessed directly
struct AuthenticationWebService {
    var signUp = signUp(with:)
    var logIn = logIn(with:)
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

// MARK: - Helpers
private extension Request {
    static func makeSignUp(with parameters: SignUpParameters) -> Request {
        return Request(url: Endpoint.signUp.url, method: .post, bodyParameters: parameters, dateEncodingStrategy: nil, headers: nil, dateDecodingStrategy: nil)
    }
    
    static func makeBasicAuthenticated(with parameters: LogInParameters) -> Request {
        return Request(url: Endpoint.login.url, method: .post, headers: ["Authorization": "Basic \(parameters.makeBase64String())"], dateDecodingStrategy: nil)
    }
}
