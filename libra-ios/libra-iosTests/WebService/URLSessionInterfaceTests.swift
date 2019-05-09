import XCTest
@testable import libra_ios

class URLSessionInterfaceTests: XCTestCase {
    var session: PartialMockURLSession!
    let request = Request<User>(url: URL(string: "https://libra.co")!, method: .get, headers: nil, dateDecodingStrategy: nil)
    
    override func setUp() {
        super.setUp()
        
        Current = .mock
        
        session = PartialMockURLSession()
    }

    override func tearDown() {
        super.tearDown()
        
        session = nil
    }
    
    func testThatSendAsksDataTaskResponseHandlerToUnwrapData() {
        var unwrapDataCallCount = 0
        Current.dataTaskResponseHandler.unwrapData = { _, _, _ in
            unwrapDataCallCount += 1
            return Data()
        }
        
        session.send(request).waitAndAssert(on: self) { _ in
            XCTAssertEqual(unwrapDataCallCount, 1)
        }
    }
    
    func testThatSendTokenAuthenticatedRequestAsksStorageToFetchToken() {
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        _ = session.sendTokenAuthenticatedRequest(to: .user(id: 999), method: .get) as Future<Result<User, NetworkError>>
        
        XCTAssertEqual(fetchTokenCallCount, 1)
        
        let parameters = UpdateUserParameters(id: 999, firstName: "sheng", lastName: "wu", email: "shengwu@libra.co")
        _ = session.sendTokenAuthenticatdRequest(to: .user(id: 999), method: .put, parameters: parameters) as Future<Result<User, NetworkError>>
        
        XCTAssertEqual(fetchTokenCallCount, 2)
    }
    
    func testThatSendTokenAuthenticatedRequestThrowsMissingTokenIfFetchTokenFails() {
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            throw PersistingError.noEntity
        }
        
        let noParametersFuture: Future<Result<User, NetworkError>> = session.sendTokenAuthenticatedRequest(to: .user(id: 999), method: .get)
        noParametersFuture.waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Send should fail")
            case .failure(let error):
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .missingToken)
            }
        }
        
        let parameters = UpdateUserParameters(id: 999, firstName: "sheng", lastName: "wu", email: "shengwu@libra.co")
        let withParametersFuture: Future<Result<User, NetworkError>> = session.sendTokenAuthenticatdRequest(to: .user(id: 999), method: .put, parameters: parameters)
        withParametersFuture.waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Send should fail")
            case .failure(let error):
                XCTAssertEqual(fetchTokenCallCount, 2)
                XCTAssertEqual(error, .missingToken)
            }
        }
    }
}
