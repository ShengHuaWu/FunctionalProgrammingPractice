extension URLSessionInterface {
    func send<Entity>(_ request: Request<Entity>) -> Future<Result<Entity, NetworkError>> where Entity: Decodable {
        return Current.dataTaskResponseHandler.unwrapData |> curry(send)(request)
    }
    
    func sendTokenAuthenticatedRequest<Entity>(to endpoint: Endpoint, method: HTTPMethod) -> Future<Result<Entity, NetworkError>> where Entity: Decodable {
        do {
            return (endpoint, method, try Current.storage.fetchToken())
                |> Request<Entity>.makeTokenAuthenticatd(to:method:token:)
                >>> send
        } catch {
            return Future { callback in
                callback(.failure(.missingToken))
            }
        }
    }
    
    func sendTokenAuthenticatdRequest<Entity, Parameters>(to endpoint: Endpoint, method: HTTPMethod, parameters: Parameters) -> Future<Result<Entity, NetworkError>> where Entity: Decodable, Parameters: Encodable {
        do {
            return (endpoint, method, try Current.storage.fetchToken(), parameters)
                |> Request.makeTokenAuthenticated(to:method:token:parameters:)
                >>> send
        } catch {
            return Future { callback in
                callback(.failure(.missingToken))
            }
        }
    }
}

// MARK: - Helpers
private extension Request {
    static func makeTokenAuthenticatd(to endpoint: Endpoint, method: HTTPMethod, token: String) -> Request {
        return Request(url: endpoint.url, method: method, headers: ["Authorization": "Bearer \(token)"], dateDecodingStrategy: .iso8601)
    }
    
    static func makeTokenAuthenticated<Parameters>(to endpoint: Endpoint, method: HTTPMethod, token: String, parameters: Parameters) -> Request where Parameters: Encodable {
        return Request(url: endpoint.url, method: method, bodyParameters: parameters, dateEncodingStrategy: .millisecondsSince1970, headers: ["Authorization": "Bearer \(token)"], dateDecodingStrategy: .iso8601)
    }
}
