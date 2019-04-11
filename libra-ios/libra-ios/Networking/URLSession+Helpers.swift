import Foundation

extension URLSession {
    func send<Entity>(_ request: Request<Entity>, completion: @escaping (Result<Entity, NetworkError>) -> Void) where Entity: Decodable {
        let task = dataTask(with: request.urlRequest) { data, urlResponse, error in
            do {
                // The order of composition:
                // sanitize error >>> sanitize data >>> sanitize url response >>> unwrap data
                let unwrappedData = try (data, urlResponse, error) |> DataTaskResponse.init |> sanitizeError(for:) >>> sanitizeData(for:) >>> sanitizeURLResponse(for:) >>> unwrapDataAfterSanitizing(for:)
                let entity = try request.parse(unwrappedData)
                completion(.success(entity))
            } catch let error as NetworkError {
                completion(.failure(error))
            } catch {
                completion(.failure(NetworkError.failure(mesage: error.localizedDescription)))
            }
        }
        task.resume()
    }
}
