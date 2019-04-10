import Foundation

enum NetworkError: Error {
    // TODO: More cases are needed
    case failure(mesage: String)
    case unexpectedResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case clientError
    case serverError
}
