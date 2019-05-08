import Foundation

enum NetworkError: Error {
    case failure(mesage: String)
    case unexpectedResponse
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case clientError(reason: String?)
    case serverError
    case missingToken
}

extension NetworkError: Equatable {}
