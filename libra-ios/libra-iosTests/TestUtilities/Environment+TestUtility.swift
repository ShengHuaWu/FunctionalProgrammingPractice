import Foundation
@testable import libra_ios

extension DataTaskResponseHandler {
    static let mock = DataTaskResponseHandler(unwrapData: { _, _, _ in
        return try JSONEncoder().encode(SuccessResponse())
    })
}

extension WebService {
    static let mock = WebService(
        signUp: { _ in return .empty },
        logIn: { _ in return .empty },
        getUser: { _ in return .empty },
        updateUser: { _ in return .empty })
}

extension Storage {
    static let mock = Storage(
        saveToken: { _ in },
        fetchToken: { return "" },
        deleteToken: {})
}

extension Environment {
    static let mock = Environment(
        urlSession: { return MockURLSessionInterface() },
        dataTaskResponseHandler: .mock,
        webService: .mock,
        storage: .mock)
}
