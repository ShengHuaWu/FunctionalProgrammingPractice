import Foundation

extension URLSession {
    func send<Entity>(_ request: Request<Entity>, completion: @escaping (Result<Entity, NetworkError>) -> Void) where Entity: Decodable {
        let task = dataTask(with: request.urlRequest) { data, response, error in
            do {
                let data = try ResponseHandler.unwrap(data: data, response: response, error: error)
                let entity = try request.parse(data)
                completion(.success(entity))
            } catch let error as NetworkError {
                completion(.failure(error))
            } catch {
                // TODO: Should not happen
                fatalError()
            }
        }
        task.resume()
    }
}
