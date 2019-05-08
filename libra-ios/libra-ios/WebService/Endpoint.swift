import Foundation

enum Endpoint {
    case signUp
    case login
    case user(id: Int)
    case records
    case record(id: Int)
    case search(key: String)
    case friends(userID: Int)
    case friend(userID: Int, friendID: Int)
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
        case .record(let id): return baseURL.appendingPathComponent("records/\(id)")
        case .search(let key): return baseURL.appendingPathComponent("users/search").appending(queryItems: [URLQueryItem(name: "q", value: key)])
        case .friends(let userID): return baseURL.appendingPathComponent("users/\(userID)/friends")
        case let .friend(userID, friendID): return baseURL.appendingPathComponent("users/\(userID)/friends/\(friendID)")
        }
    }
}

// MARK: - Helpers
private extension URL {
    func appending(queryItems: [URLQueryItem]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Unable to create url components from \(absoluteString)")
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            preconditionFailure("Unable to generate url from query items")
        }
        
        return url
    }
}
