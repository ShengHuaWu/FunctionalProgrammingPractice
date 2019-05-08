import XCTest
@testable import libra_ios

class WebServiceFriendsTests: XCTestCase {
    var webService: WebService!
    var urlSessionInterface: MockURLSessionInterface!
    let user = User(id: 999, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co", token: "987654321")
    
    override func setUp() {
        super.setUp()
        
        Current = .mock
        
        urlSessionInterface = MockURLSessionInterface()
        webService = WebService()
    }
    
    override func tearDown() {
        super.tearDown()
        
        urlSessionInterface = nil
        webService = nil
    }
    
    func testThatGetAllFriendsReturnsUsersIfSuccess() {
        urlSessionInterface.expectedEntity = [user]
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.getAllFriends(999).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.count, 1)
                XCTAssertEqual(entity.first?.id, self.user.id)
            case .failure:
                XCTFail("Get all friends should succeed")
            }
        }
    }
    
    func testThatGetAllFriendsReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.getAllFriends(999).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Get all friends should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatAddFriendshipReturnsSuccessRepsonseIfSuccess() {
        urlSessionInterface.expectedEntity = SuccessResponse()
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = FriendshipParameters(userID: user.id, personID: user.id)
        webService.addFriendship(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertTrue(entity.success)
            case .failure:
                XCTFail("Add friendship should succeed")
            }
        }
    }
    
    func testThatAddFriendshipReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = FriendshipParameters(userID: user.id, personID: user.id)
        webService.addFriendship(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Add friendship should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatGetFriendReturnsUserIfSuccess() {
        urlSessionInterface.expectedEntity = user
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = FriendshipParameters(userID: user.id, personID: user.id)
        webService.getFriend(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.id, self.user.id)
            case .failure:
                XCTFail("Get friend should succeed")
            }
        }
    }
    
    func testThatGetFriendReturnsNetworkIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = FriendshipParameters(userID: user.id, personID: user.id)
        webService.getFriend(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Get friend should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatRemoveFriendshipReturnsSuccessResponseIfSuccess() {
        urlSessionInterface.expectedEntity = SuccessResponse()
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = FriendshipParameters(userID: user.id, personID: user.id)
        webService.removeFriendship(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertTrue(entity.success)
            case .failure:
                XCTFail("Remove friendship should succeed")
            }
        }
    }
    
    func testThatRemoveFriendshipReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = FriendshipParameters(userID: user.id, personID: user.id)
        webService.removeFriendship(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Remove friendship should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
}
