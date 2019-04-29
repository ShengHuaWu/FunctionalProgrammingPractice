import Foundation

struct Environment {
    var urlSession: () -> URLSessionInterface = { return URLSession(configuration: .json) }
    var dataTaskResponseHandler = DataTaskResponseHandler()
    var webService = WebService()
    var storage = Storage()
}

var Current = Environment()
