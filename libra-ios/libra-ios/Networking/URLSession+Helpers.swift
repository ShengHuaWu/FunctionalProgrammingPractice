import Foundation

extension URLSession {
    func send<Entity>(_ request: Request<Entity>) -> Future<Result<Entity, NetworkError>> where Entity: Decodable {
        return Future { callback in
            defer { self.finishTasksAndInvalidate() }
            
            let task = self.dataTask(with: request.urlRequest) { data, urlResponse, error in
                do {
                    // The order of composition:
                    // sanitize error >>> sanitize data >>> sanitize url response >>> unwrap data
                    let unwrappedData = try (data, urlResponse, error) |> DataTaskResponse.init |> sanitizeError(for:) >>> sanitizeData(for:) >>> sanitizeURLResponse(for:) >>> unwrapDataAfterSanitizing(for:)
                    let entity = try request.parse(unwrappedData)
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
