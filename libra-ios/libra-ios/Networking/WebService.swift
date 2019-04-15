import Foundation

struct WebService {
    var signUp = signUp(with:)
}

private func signUp(with parameters: SignUpParameters) -> Future<Result<User, NetworkError>> {
    let url = URL.base.appendingPathComponent(for: .signUp)
    let request = Request<User>(url: url, method: .post, bodyParameters: parameters)
    let session = URLSession(configuration: .base)
    
    return session.send(request)
}
