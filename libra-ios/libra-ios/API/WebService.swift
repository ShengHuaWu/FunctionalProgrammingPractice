import Foundation

struct WebService {
    var signUp = signUp(with:)
    var logIn = logIn(with:)
    var getUser = getUser(with:)
    var updateUser = updateUser(with:)
    var getRecords = getAllRecords
    var getRecord = getRecords(with:)
}

// MARK: - Private
private func signUp(with parameters: SignUpParameters) -> Future<Result<User, NetworkError>> {
    return (Endpoint.signUp.url, HTTPMethod.post, parameters, nil)
        |> Request<User>.init
        >>> send
}

private func logIn(with parameters: LoginParameters) -> Future<Result<User, NetworkError>> {
    return (Endpoint.login.url, HTTPMethod.post, ["Authorization": "Basic \(parameters.makeBase64String())"])
        |> Request<User>.init
        >>> send
}

private func getUser(with id: Int) -> Future<Result<User, NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .user(id: id), method: .get)
}

private func updateUser(with parameters: UpdateUserParameters) -> Future<Result<User, NetworkError>> {
    return sendTokenAuthenticatdRequest(to: .user(id: parameters.userID), method: .put, parameters: parameters)
}

private func getAllRecords() -> Future<Result<[Record], NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .records, method: .get)
}

private func getRecords(with id: Int) -> Future<Result<Record, NetworkError>> {
    return sendTokenAuthenticatedRequest(to: .record(id: id), method: .get)
}

// MARK: - Helpers
private func send<Entity>(_ request: Request<Entity>) -> Future<Result<Entity, NetworkError>> {
    return Current.dataTaskResponseHandler.unwrapData |> curry(Current.urlSession().send)(request)
}

private func sendTokenAuthenticatedRequest<Entity>(to endpoint: Endpoint, method: HTTPMethod) -> Future<Result<Entity, NetworkError>> where Entity: Decodable {
    do {
        let token = try Current.storage.fetchToken()

        return (endpoint.url, method, ["Authorization": "Bearer \(token)"])
            |> Request<Entity>.init
            >>> send
    } catch {
        return Future { callback in
            callback(.failure(.failure(mesage: "Unable to fetch token")))
        }
    }
}

private func sendTokenAuthenticatdRequest<Entity, Parameters>(to endpoint: Endpoint, method: HTTPMethod, parameters: Parameters) -> Future<Result<Entity, NetworkError>> where Entity: Decodable, Parameters: Encodable {
    do {
        let token = try Current.storage.fetchToken()
        
        return (endpoint.url, method, parameters, ["Authorization": "Bearer \(token)"])
            |> Request<Entity>.init
            >>> send
    } catch {
        return Future { callback in
            callback(.failure(.failure(mesage: "Unable to fetch token")))
        }
    }
}
