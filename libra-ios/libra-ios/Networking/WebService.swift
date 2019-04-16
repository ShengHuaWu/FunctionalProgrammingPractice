import Foundation

struct WebService {
    var signUp = signUp(with:)
    var logIn = logIn(with:)
}

private func signUp(with parameters: SignUpParameters) -> Future<Result<User, NetworkError>> {
    return (Endpoint.signUp.url, HTTPMethod.post, parameters, nil)
        |> Request<User>.init
        |> Current.urlSession().send
}

private func logIn(with parameters: LoginParameters) -> Future<Result<User, NetworkError>> {
    return (Endpoint.login.url, HTTPMethod.post, ["Authorization": "Basic \(parameters.makeBase64String())"])
        |> Request<User>.init
        |> Current.urlSession().send
}
