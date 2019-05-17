import Foundation
@testable import libra_ios

extension DataTaskResponseHandler {
    static let mock = DataTaskResponseHandler(unwrapData: { _, _, _ in
        return try JSONEncoder().encode(ErrorResponse(error: true, reason: "This is an error response"))
    })
}

extension WebService {
    static let mock = WebService(authentication: .mock, users: .mock, records: .mock, friends: .mock)
}

extension AuthenticationWebService {
    static let mock = AuthenticationWebService(
        signUp: { _ in return .empty },
        logIn: { _ in return .empty })
}

extension UsersWebService {
    static let mock = UsersWebService(
        get: { _ in return .empty },
        update: { _ in return .empty },
        search: { _ in return .empty})
}

extension RecordsWebService {
    static let mock = RecordsWebService(
        getAll: { return .empty },
        get: { _ in return .empty },
        create: { _ in return .empty },
        update: { _ in return .empty },
        delete: { _ in return .empty })
}

extension FriendsWebService {
    static let mock = FriendsWebService(
        getAll: { _ in return .empty },
        addFriendship: { _ in return .empty },
        get: { _ in return .empty },
        removeFriendship: { _ in return .empty })
}

extension AuthenticationStorage {
    static let mock = AuthenticationStorage(
        saveToken: { _ in throw PersistingError.noEntity },
        fetchToken: { throw PersistingError.noEntity },
        deleteToken: { throw PersistingError.noEntity })
}

extension UserStorage {
    static let mock = UserStorage(
        save: { _ in throw PersistingError.noEntity },
        fetch: { throw PersistingError.noEntity },
        delete: { throw PersistingError.noEntity },
        saveChangingActions: { _ in throw PersistingError.noEntity },
        fetchChangingActions: { throw PersistingError.noEntity },
        deleteChangingActions: { throw PersistingError.noEntity })
}

extension RecordsStorage {
    static let mock = RecordsStorage(
        save: { _ in throw PersistingError.noEntity },
        fetch: { throw PersistingError.noEntity },
        delete: { throw PersistingError.noEntity })
}

extension FriendsStorage {
    static let mock = FriendsStorage(
        save: { _ in throw PersistingError.noEntity },
        fetch: { throw PersistingError.noEntity },
        delete: { throw PersistingError.noEntity })
}

extension Storage {
    static let mock = Storage(authentication: .mock, user: .mock, records: .mock, friends: .mock)
}

extension Environment {
    static let mock = Environment(
        urlSession: { return MockURLSessionInterface() },
        dataTaskResponseHandler: .mock,
        webService: .mock,
        storage: .mock)
}
