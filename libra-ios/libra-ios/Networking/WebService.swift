import Foundation

struct WebService {
    var signUp = signUp(with:)
    var logIn = logIn(with:)
}

private func signUp(with parameters: SignUpParameters) -> Future<Result<User, NetworkError>> {
    let request = Request<User>(url: Endpoint.signUp.url, method: .post, bodyParameters: parameters)
    let session = URLSession(configuration: .base)
    
    return request |> session.send
}

private func logIn(with parameters: LoginParameters) -> Future<Result<User, NetworkError>> {
    let request = Request<User>(url: Endpoint.login.url, method: .post, headers: ["Authorization": "Basic \(parameters.makeBase64String())"])
    let session = URLSession(configuration: .base)
    
    return request |> session.send
}
