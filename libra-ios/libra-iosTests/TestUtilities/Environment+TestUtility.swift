@testable import libra_ios

extension WebService {
    static let mock = WebService(
        signUp: { _ in return Future.empty },
        logIn: { _ in return Future.empty })
}

extension Environment {
    static let mock = Environment(urlSession: { return MockURLSessionInterface() },
                                  webService: .mock)
}
