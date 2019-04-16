import Foundation

protocol URLSessionInterface {
    func finishTasksAndInvalidate()
    func dataTaskInterface(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskInterface
    func send<Entity>(_ request: Request<Entity>, unwrapData: @escaping (DataTaskResponse) throws -> Data) -> Future<Result<Entity, NetworkError>> where Entity: Decodable
}

protocol URLSessionDataTaskInterface {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskInterface {}

extension URLSession: URLSessionInterface {
    func dataTaskInterface(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskInterface {
        return dataTask(with: request, completionHandler: completionHandler)
    }
    
    func send<Entity>(_ request: Request<Entity>, unwrapData: @escaping (DataTaskResponse) throws -> Data) -> Future<Result<Entity, NetworkError>> where Entity: Decodable {
        return Future { callback in
            let task: URLSessionDataTaskInterface = self.dataTaskInterface(with: request.urlRequest) { data, urlResponse, error in
                defer { self.finishTasksAndInvalidate() }
                
                do {
                    let entity = try (data, urlResponse, error)
                        |> DataTaskResponse.init
                        |> unwrapData
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
