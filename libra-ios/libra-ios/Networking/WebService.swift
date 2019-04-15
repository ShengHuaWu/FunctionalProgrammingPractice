import Foundation

struct WebService {
    var signUp = signUp(with:)
}

private func signUp(with parameters: SignUpParameters) -> Future<Result<User, NetworkError>> {
    let request = Request<User>(url: Endpoint.signUp.url, method: .post, bodyParameters: parameters)
    let session = URLSession(configuration: .base)
    
    return request |> session.send
}
