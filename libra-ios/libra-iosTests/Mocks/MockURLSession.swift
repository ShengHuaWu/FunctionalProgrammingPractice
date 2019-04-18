import Foundation
@testable import libra_ios

final class MockURLSessionDataTask: URLSessionDataTask {
    private(set) var resumeCallCount = 0
    
    override func resume() {
        resumeCallCount += 1
    }
}

// This class is used for testing the `send` method of `URLSession`
final class PartialMockURLSession: URLSession {
    private(set) var dataTaskCallCount = 0
    private(set) var finishTasksAndInvalidateCallCount = 0
    let dataTask = MockURLSessionDataTask()
    
    override func finishTasksAndInvalidate() {
        finishTasksAndInvalidateCallCount += 1
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        completionHandler(nil, nil, nil)
        
        return dataTask
    }
}

// This class is used for testing `WebService`
final class MockURLSessionInterface: URLSessionInterface {
    private(set) var sendCallCount = 0
    var expectedError: NetworkError?
    var expectedEntity: Any?
    
    func finishTasksAndInvalidate() {}
    
    func dataTaskInterface(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskInterface {
        return MockURLSessionDataTask()
    }
    
    func send<Entity>(_ request: Request<Entity>, unwrapData: @escaping UnwrapDataHandler) -> Future<Result<Entity, NetworkError>> where Entity : Decodable {
        sendCallCount += 1
        
        return Future { callback in
            if let error = self.expectedError {
                callback(.failure(error))
            } else {
                let entity = self.expectedEntity as! Entity
                callback(.success(entity))
            }
        }
    }
}
