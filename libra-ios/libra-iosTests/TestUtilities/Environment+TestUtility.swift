import Foundation
@testable import libra_ios

extension DataTaskResponseHandler {
    static let mock = DataTaskResponseHandler(unwrapData: { _, _, _ in
        return try JSONEncoder().encode(ErrorResponse(error: true, reason: "This is an error response"))
    })
}

extension WebService {
    static let mock = WebService(
        signUp: { _ in return .empty },
        logIn: { _ in return .empty },
        getUser: { _ in return .empty },
        updateUser: { _ in return .empty },
        getRecords: { return .empty })
}

extension Storage {
    static let mock = Storage(
        saveToken: { _ in throw PersistingError.noEntity },
        fetchToken: { throw PersistingError.noEntity },
        deleteToken: { throw PersistingError.noEntity })
}

extension Environment {
    static let mock = Environment(
        urlSession: { return MockURLSessionInterface() },
        dataTaskResponseHandler: .mock,
        webService: .mock,
        storage: .mock)
}
