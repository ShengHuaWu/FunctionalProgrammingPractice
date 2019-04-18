import XCTest
@testable import libra_ios

// This test case checks the `send` method
class URLSessionHelpersTests: XCTestCase {
    var session: PartialMockURLSession!
    var request: Request<SuccessResponse>!

    override func setUp() {
        super.setUp()
        
        session = PartialMockURLSession()
        request = Request<SuccessResponse>(url: URL(string: "https://libra.co")!, method: .get)
    }
    
    override func tearDown() {
        super.tearDown()
        
        session = nil
        request = nil
    }
        
    func testThatSendReturnsFailureIfUnwrapDataFails() {
        let fakeError = FakeError.fake
        let unwrapData: UnwrapDataHandler = { _, _, _ in
            throw fakeError
        }
        
        session.send(request, unwrapData: unwrapData).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Result should be failure")
            case .failure(let error):
                XCTAssertEqual(self.session.dataTaskCallCount, 1)
                XCTAssertEqual(self.session.finishTasksAndInvalidateCallCount, 1)
                XCTAssertEqual(self.session.dataTask.resumeCallCount, 1)
                XCTAssertEqual(error, .failure(mesage: fakeError.localizedDescription))
            }
        }
    }
    
    func testThatSendReturnsSuccessIfUnwrapDataSucceeds() {
        let unwrapData: UnwrapDataHandler = { _, _, _ in
            return try JSONEncoder().encode(SuccessResponse())
        }
        
        session.send(request, unwrapData: unwrapData).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.session.dataTaskCallCount, 1)
                XCTAssertEqual(self.session.finishTasksAndInvalidateCallCount, 1)
                XCTAssertEqual(self.session.dataTask.resumeCallCount, 1)
                XCTAssertEqual(entity.success, true)
            case .failure:
                XCTFail("Result should be success")
            }
        }
    }
}
