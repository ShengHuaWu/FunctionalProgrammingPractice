import Foundation

struct Environment {
    var urlSession: () -> URLSessionInterface = { return URLSession(configuration: .base) }
    var webService = WebService()
}

var Current = Environment()
