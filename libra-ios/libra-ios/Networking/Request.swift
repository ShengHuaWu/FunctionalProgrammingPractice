import Foundation

struct Request<Entity> where Entity: Decodable {
    let urlRequest: URLRequest
    let parse: (Data) throws -> Entity
    
    init(url: URL, method: HTTPMethod, headers: [String: String]?, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        
        self.urlRequest = urlRequest
        self.parse = { data in
            let decoder = JSONDecoder()
            if let strategy = dateDecodingStrategy {
                decoder.dateDecodingStrategy = strategy
            }
            return try decoder.decode(Entity.self, from: data)
        }
    }
    
    init<Parameter>(url: URL, method: HTTPMethod, bodyParameters: Parameter, dateEncodingStrategy: JSONEncoder.DateEncodingStrategy?, headers: [String: String]?, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?) where Parameter: Encodable {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        let encoder = JSONEncoder()
        if let strategy = dateEncodingStrategy {
            encoder.dateEncodingStrategy = strategy
        }
        guard let body = try? encoder.encode(bodyParameters) else {
            preconditionFailure("Unable to encode \(Parameter.self) to JSON")
        }
        urlRequest.httpBody = body
        
        urlRequest.allHTTPHeaderFields = headers
        
        self.urlRequest = urlRequest
        self.parse = { data in
            let decoder = JSONDecoder()
            if let strategy = dateDecodingStrategy {
                decoder.dateDecodingStrategy = strategy
            }
            return try decoder.decode(Entity.self, from: data)
        }
    }
    
    // TODO: Multi-parts upload request
}
