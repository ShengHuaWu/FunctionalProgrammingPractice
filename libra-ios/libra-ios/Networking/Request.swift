import Foundation

struct Request<Entity> where Entity: Decodable {
    let urlRequest: URLRequest
    let parse: (Data) throws -> Entity
    
    init(url: URL, method: HTTPMethod, headers: [String: String]? = nil) throws {
        self = try .init(url: url, method: method, bodyParameter: EmptyParameter(), headers: headers)
    }
    
    init<Parameter>(url: URL, method: HTTPMethod, bodyParameter: Parameter, headers: [String: String]? = nil) throws where Parameter: Encodable {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if !(bodyParameter is EmptyParameter) {
            urlRequest.httpBody = try JSONEncoder().encode(bodyParameter)
        }
        urlRequest.allHTTPHeaderFields = headers
        
        self.urlRequest = urlRequest
        self.parse = { data in try JSONDecoder().decode(Entity.self, from: data) }
    }
}

// MARK: Private
private extension Request {
    struct EmptyParameter: Encodable {} // Use this type to erase the generic constraint in the initializer
}
