enum Endpoint {
    case signUp
}

extension Endpoint {
    var path: String {
        switch self {
        case .signUp: return "users/signup"
        }
    }
}
