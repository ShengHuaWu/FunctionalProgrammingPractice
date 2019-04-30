import Foundation

// TODO: Determine which should be exposed for application layer
struct Environment {
    var urlSession: () -> URLSessionInterface = { return URLSession(configuration: .json) }
    var dataTaskResponseHandler = DataTaskResponseHandler()
    var webService = WebService()
    var storage = Storage()
}

var Current = Environment()
