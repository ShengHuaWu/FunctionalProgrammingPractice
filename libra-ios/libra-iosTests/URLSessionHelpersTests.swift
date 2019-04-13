import XCTest
@testable import libra_ios

final class MockURLSession: URLSession {
    private(set) var dataTaskCallCount = 0
    private(set) var finishTasksAndInvalidateCallCount = 0
    var expectedData: Data?
    var expectedURLResponse: URLResponse?
    var expectedError: Error?
    let dataTask = MockURLSessionDataTask()
    
    override func finishTasksAndInvalidate() {
        finishTasksAndInvalidateCallCount += 1
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        completionHandler(expectedData, expectedURLResponse, expectedError)
        
        return dataTask
    }
}

final class MockURLSessionDataTask: URLSessionDataTask {
    private(set) var resumeCallCount = 0
    
    override func resume() {
        resumeCallCount += 1
    }
}

class URLSessionHelpersTests: XCTestCase {
    var session: MockURLSession!
    var request: Request<SuccessResponse>!
    let errorResponse = ErrorResponse(error: true, reason: "An error occurs")
    let successResponse = SuccessResponse()

    override func setUp() {
        super.setUp()
        
        session = MockURLSession()
        request = Request<SuccessResponse>(url: URL(string: "https://libra.co")!, method: .get)
    }
    
    override func tearDown() {
        super.tearDown()
        
        session = nil
        request = nil
    }
    
    // The following tests are checking the order of function composition
    
    func testThatSendReturnsFailureIfErrorOccurs() {
        let fakeError = FakeError.fake
        session.expectedError = fakeError
        session.expectedURLResponse = HTTPURLResponse.makeFake(with: 200)
        session.expectedData = try! JSONEncoder().encode(errorResponse)
        
        session.send(request).assertAndWait(on: self) { result in
            switch result {
            case .success:
                XCTFail("Result should be failure")
            case .failure(let error):
                XCTAssertEqual(self.session.finishTasksAndInvalidateCallCount, 1)
                XCTAssertEqual(self.session.dataTask.resumeCallCount, 1)
                XCTAssertEqual(error, .failure(mesage: fakeError.localizedDescription))
            }
        }
    }
    
    func testThatSendReturnsFailureIfDataIfErrorResponse() {
        session.expectedURLResponse = HTTPURLResponse.makeFake(with: 200)
        session.expectedData = try! JSONEncoder().encode(errorResponse)
        
        session.send(request).assertAndWait(on: self) { result in
            switch result {
            case .success:
                XCTFail("Result should be failure")
            case .failure(let error):
                XCTAssertEqual(self.session.finishTasksAndInvalidateCallCount, 1)
                XCTAssertEqual(self.session.dataTask.resumeCallCount, 1)
                XCTAssertEqual(error, .clientError(reason: self.errorResponse.reason))
            }
        }
    }
    
    func testThatSendReturnsFailureIfStatusCodeIs400() {
        let httpURLResponse = HTTPURLResponse.makeFake(with: 400)
        session.expectedURLResponse = httpURLResponse
        session.expectedData = try! JSONEncoder().encode(successResponse)
        
        session.send(request).assertAndWait(on: self) { result in
            switch result {
            case .success:
                XCTFail("Result should be failure")
            case .failure(let error):
                XCTAssertEqual(self.session.finishTasksAndInvalidateCallCount, 1)
                XCTAssertEqual(self.session.dataTask.resumeCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatSendReturnsSuccessIfEverythingIsFine() {
        let httpURLResponse = HTTPURLResponse.makeFake(with: 200)
        session.expectedURLResponse = httpURLResponse
        session.expectedData = try! JSONEncoder().encode(successResponse)
        
        session.send(request).assertAndWait(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.session.finishTasksAndInvalidateCallCount, 1)
                XCTAssertEqual(self.session.dataTask.resumeCallCount, 1)
                XCTAssertEqual(entity.success, true)
            case .failure:
                XCTFail("Result should be success")
            }
        }
    }
}
