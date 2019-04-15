import Foundation

extension URLSession {
    func send<Entity>(_ request: Request<Entity>) -> Future<Result<Entity, NetworkError>> where Entity: Decodable {
        return Future { callback in
            let task = self.dataTask(with: request.urlRequest) { data, urlResponse, error in
                defer { self.finishTasksAndInvalidate() }

                do {
                    // The order of composition:
                    // sanitize error >>> sanitize data >>> sanitize url response >>> unwrap data >>> parse
                    let entity = try (data, urlResponse, error)
                        |> DataTaskResponse.init
                        |> sanitizeError(for:)
                        >>> sanitizeData(for:)
                        >>> sanitizeURLResponse(for:)
                        >>> unwrapDataAfterSanitizing(for:)
                        >>> request.parse
                    callback(.success(entity))
                } catch let error as NetworkError {
                    callback(.failure(error))
                } catch {
                    callback(.failure(NetworkError.failure(mesage: error.localizedDescription)))
                }
            }
            task.resume()
        }
    }
}
