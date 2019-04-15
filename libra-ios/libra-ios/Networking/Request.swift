import Foundation

struct Request<Entity> where Entity: Decodable {
    let urlRequest: URLRequest
    let parse: (Data) throws -> Entity
    
    init(url: URL, method: HTTPMethod, headers: [String: String]? = nil) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        self.urlRequest = urlRequest
        self.parse = { data in try JSONDecoder().decode(Entity.self, from: data) }
    }
    
    init<Parameter>(url: URL, method: HTTPMethod, bodyParameters: Parameter, headers: [String: String]? = nil) where Parameter: Encodable {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        guard let body = try? JSONEncoder().encode(bodyParameters) else {
            preconditionFailure("Unable to encode \(Parameter.self) to JSON")
        }
        urlRequest.httpBody = body
        
        urlRequest.allHTTPHeaderFields = headers
        
        self.urlRequest = urlRequest
        self.parse = { data in try JSONDecoder().decode(Entity.self, from: data) }
    }
}
