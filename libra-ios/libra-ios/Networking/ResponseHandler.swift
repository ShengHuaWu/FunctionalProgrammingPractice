import Foundation

struct ResponseHandler {
    static func unwrap(data: Data?, response: URLResponse?, error: Error?) throws -> Data {
        // TODO: Implementation is needed
        fatalError()
    }
}

// MARK: - Private
private extension ResponseHandler {
    static func santize(error: Error?) throws {
        if let unwrappedError = error {
            throw NetworkError.failure(mesage: unwrappedError.localizedDescription)
        }
    }
    
    static func santize(response: URLResponse?) throws {
        guard let httpURLResponse = response as? HTTPURLResponse else {
            throw NetworkError.unexpectedResponse
        }
        
        switch httpURLResponse.statusCode {
        case 400:
            throw NetworkError.badRequest
        case 402:
            throw NetworkError.clientError
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 405 ... 499:
            throw NetworkError.clientError
        case 500 ... 599:
            throw NetworkError.serverError
        default:
            break
        }
    }
    
//    static func santize(data: Data?) throws -> Data {
//        guard let unwrappedData = data else {
//            throw NetworkError
//        }
//    }
}
