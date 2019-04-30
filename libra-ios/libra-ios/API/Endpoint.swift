import Foundation

enum Endpoint {
    case signUp
    case login
    case user(id: Int)
    case records
}

extension Endpoint {
    var url: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "Base URL") as? String,
            let baseURL = URL(string: urlString) else {
                preconditionFailure("Unable to load base url from info.plist")
        }
        
        switch self {
        case .signUp: return baseURL.appendingPathComponent("users/signup")
        case .login: return  baseURL.appendingPathComponent("users/login")
        case .user(let id): return baseURL.appendingPathComponent("users/\(id)")
        case .records: return baseURL.appendingPathComponent("records")
        }
    }
}
