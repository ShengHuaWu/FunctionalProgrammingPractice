import Foundation

struct Request<Entity> where Entity: Decodable {
    let urlRequest: URLRequest
    let parse: (Data) throws -> Entity
    
    // This is used for GET & DELETE requests
    init(url: URL, method: HTTPMethod, headers: [String: String]? = nil) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        self.urlRequest = urlRequest
        self.parse = { data in try JSONDecoder().decode(Entity.self, from: data) }
    }
    
    // This is used for POST & PUT requests
    init<Parameter>(url: URL, method: HTTPMethod, bodyParameter: Parameter, headers: [String: String]? = nil) throws where Parameter: Encodable {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = try JSONEncoder().encode(bodyParameter)
        urlRequest.allHTTPHeaderFields = headers
        
        self.urlRequest = urlRequest
        self.parse = { data in try JSONDecoder().decode(Entity.self, from: data) }
    }
}
