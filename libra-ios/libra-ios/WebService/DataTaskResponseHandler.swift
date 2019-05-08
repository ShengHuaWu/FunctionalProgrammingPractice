import Foundation

// Use this type to ignore the response in a success case
struct SuccessResponse: Codable {
    let success: Bool = true
}

// Use this type to parse error response
struct ErrorResponse: Codable {
    let error: Bool
    let reason: String
}

fileprivate struct DataTaskResponse {
    let data: Data?
    let urlResponse: URLResponse?
    let error: Error?
}

struct DataTaskResponseHandler {
    // The order of composition:
    // create data task response >>> sanitize error >>> sanitize data >>> sanitize url response >>> unwrap data
    var unwrapData: UnwrapDataHandler = { data, response, error in
        return try (data, response, error)
            |> DataTaskResponse.init
            >>> sanitizeError(for:)
            >>> sanitizeData(for:)
            >>> sanitizeURLResponse(for:)
            >>> unwrapDataAfterSanitizing(for:)
    }
}

private func sanitizeError(for response: DataTaskResponse) throws -> DataTaskResponse {
    if let unwrappedError = response.error {
        throw NetworkError.failure(mesage: unwrappedError.localizedDescription)
    }
    
    return response
}

private func sanitizeData(for response: DataTaskResponse) throws -> DataTaskResponse {
    guard let unwrappedData = response.data,
        let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: unwrappedData) else {
            return response
    }
    
    throw NetworkError.clientError(reason: errorResponse.reason)
}

private func sanitizeURLResponse(for response: DataTaskResponse) throws -> DataTaskResponse {
    guard let httpURLResponse = response.urlResponse as? HTTPURLResponse else {
        throw NetworkError.unexpectedResponse
    }
    
    switch httpURLResponse.statusCode {
    case 400:
        throw NetworkError.badRequest
    case 402:
        throw NetworkError.clientError(reason: nil)
    case 401:
        throw NetworkError.unauthorized
    case 403:
        throw NetworkError.forbidden
    case 404:
        throw NetworkError.notFound
    case 405 ... 499:
        throw NetworkError.clientError(reason: nil)
    case 500 ... 599:
        throw NetworkError.serverError
    default:
        break
    }
    
    return response
}

private func unwrapDataAfterSanitizing(for response: DataTaskResponse) throws -> Data {
    guard let unwrappedData = response.data, !unwrappedData.isEmpty else {
        return try JSONEncoder().encode(SuccessResponse())
    }
    
    return unwrappedData
}
