import Foundation

// TODO: Separate methods into different files: users, records, friends
struct WebService {
    var signUp = signUp(with:)
    var logIn = logIn(with:)
    var getUser = getUser(with:)
    var updateUser = updateUser(with:)
    var getRecords = getAllRecords
    var getRecord = getRecord(with:)
    var createRecord = createRecord(with:)
    var updateRecord = updateRecord(with:)
    var deleteRecord = deleteRecord(with:)
    var searchUsers = searchUsers(with:)
    var getAllFriends = getAllFriends(for:)
    var addFriendship = addFriendship(with:)
    var getFriend = getFriend(with:)
    var removeFriendship = removeFriendship(with:)
}

// MARK: - Private
private func signUp(with parameters: SignUpParameters) -> Future<Result<User, NetworkError>> {
    return parameters
        |> Request<User>.makeSignUp(with:)
        >>> send
}

private func logIn(with parameters: LogInParameters) -> Future<Result<User, NetworkError>> {
    return parameters
        |> Request<User>.makeLogIn(with:)
        >>> send
}

private func getUser(with id: Int) -> Future<Result<User, NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .user(id: id), method: .get)
}

private func updateUser(with parameters: UpdateUserParameters) -> Future<Result<User, NetworkError>> {
    return sendTokenAuthenticatdRequest(to: .user(id: parameters.id), method: .put, parameters: parameters)
}

private func getAllRecords() -> Future<Result<[Record], NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .records, method: .get)
}

private func getRecord(with id: Int) -> Future<Result<Record, NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .record(id: id), method: .get)
}

private func createRecord(with parameters: RecordParameters) -> Future<Result<Record, NetworkError>> {
    return sendTokenAuthenticatdRequest(to: .records, method: .post, parameters: parameters)
}

private func updateRecord(with parameters: RecordParameters) -> Future<Result<Record, NetworkError>> {
    guard let id = parameters.id else {
        return Future { callback in
            callback(.failure(.badRequest))
        }
    }
    
    return sendTokenAuthenticatdRequest(to: .record(id: id), method: .put, parameters: parameters)
}

private func deleteRecord(with id: Int) -> Future<Result<SuccessResponse, NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .record(id: id), method: .delete)
}

private func searchUsers(with key: String) -> Future<Result<[User], NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .search(key: key), method: .get)
}

private func getAllFriends(for userID: Int) -> Future<Result<[User], NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .friends(userID: userID), method: .get)
}

private func addFriendship(with parameters: FriendshipParameters) -> Future<Result<SuccessResponse, NetworkError>> {
    return sendTokenAuthenticatdRequest(to: .friends(userID: parameters.userID), method: .post, parameters: parameters)
}

private func getFriend(with parameters: FriendshipParameters) -> Future<Result<User, NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .friend(userID: parameters.userID, friendID: parameters.personID), method: .get)
}

private func removeFriendship(with parameters: FriendshipParameters) -> Future<Result<SuccessResponse, NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .friend(userID: parameters.userID, friendID: parameters.personID), method: .delete)
}

// MARK: - Helpers
private func send<Entity>(_ request: Request<Entity>) -> Future<Result<Entity, NetworkError>> {
    return Current.dataTaskResponseHandler.unwrapData |> curry(Current.urlSession().send)(request)
}

private func sendTokenAuthenticatedRequest<Entity>(to endpoint: Endpoint, method: HTTPMethod) -> Future<Result<Entity, NetworkError>> where Entity: Decodable {
    do {
        let token = try Current.storage.fetchToken()

        return (endpoint.url, method, ["Authorization": "Bearer \(token)"], .iso8601)
            |> Request<Entity>.init(url:method:headers:dateDecodingStrategy:)
            >>> send
    } catch {
        return Future { callback in
            callback(.failure(.missingToken))
        }
    }
}

private func sendTokenAuthenticatdRequest<Entity, Parameters>(to endpoint: Endpoint, method: HTTPMethod, parameters: Parameters) -> Future<Result<Entity, NetworkError>> where Entity: Decodable, Parameters: Encodable {
    do {
        let token = try Current.storage.fetchToken()
        
        return (endpoint.url, method, parameters, .iso8601, ["Authorization": "Bearer \(token)"], .millisecondsSince1970)
            |> Request<Entity>.init(url:method:bodyParameters:dateEncodingStrategy:headers:dateDecodingStrategy:)
            >>> send
    } catch {
        return Future { callback in
            callback(.failure(.missingToken))
        }
    }
}

private extension Request where Entity == User {
    static func makeSignUp(with parameters: SignUpParameters) -> Request {
        return Request(url: Endpoint.signUp.url, method: .post, bodyParameters: parameters, dateEncodingStrategy: nil, headers: nil, dateDecodingStrategy: nil)
    }
    
    static func makeLogIn(with parameters: LogInParameters) -> Request {
        return Request(url: Endpoint.login.url, method: .post, headers: ["Authorization": "Basic \(parameters.makeBase64String())"], dateDecodingStrategy: nil)
    }
}
