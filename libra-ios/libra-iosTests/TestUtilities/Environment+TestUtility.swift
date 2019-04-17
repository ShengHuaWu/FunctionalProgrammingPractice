import Foundation
@testable import libra_ios

extension DataTaskResponseHandler {
    static let mock = DataTaskResponseHandler(unwrapData: { _ in
        return try JSONEncoder().encode(SuccessResponse())
    })
}

extension WebService {
    static let mock = WebService(
        signUp: { _ in return Future.empty },
        logIn: { _ in return Future.empty })
}

extension Environment {
    static let mock = Environment(urlSession: { return MockURLSessionInterface() },
                                  dataTaskResponseHandler: .mock,
                                  webService: .mock)
}
