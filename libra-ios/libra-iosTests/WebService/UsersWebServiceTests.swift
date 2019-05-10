import XCTest
@testable import libra_ios

class UsersWebServiceTests: XCTestCase {
    var usersWebService: UsersWebService!
    var urlSessionInterface: MockURLSessionInterface!
    let user = User(id: 999, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co", token: "987654321")
    let record = Record(id: 999, title: "Libra Record", note: "This is just one record", date: Date(), amount: 100, currency: .usd, mood: .good, companions: [Companion(id: 999, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co")])

    override func setUp() {
        super.setUp()
        
        Current = .mock
        
        urlSessionInterface = MockURLSessionInterface()
        usersWebService = UsersWebService()
    }
    
    override func tearDown() {
        super.tearDown()
        
        urlSessionInterface = nil
        usersWebService = nil
    }
    
    func testThatSignUpReturnsUserIfSuccess() {
        urlSessionInterface.expectedEntity = user
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameter = SignUpParameters(username: user.username, password: "", firstName: user.firstName, lastName: user.lastName  , email: user.email)
        usersWebService.signUp(parameter).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(entity.id, self.user.id)
            case .failure:
                XCTFail("Signup should succeed")
            }
        }
    }
    
    func testThatSignUpReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameter = SignUpParameters(username: user.username, password: "", firstName: user.firstName, lastName: user.lastName  , email: user.email)
        usersWebService.signUp(parameter).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Signup should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatLogInReturnsUserIfSuccess() {
        urlSessionInterface.expectedEntity = user
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameters = LogInParameters(username: user.username, password: "")
        usersWebService.logIn(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(entity.id, self.user.id)
            case .failure:
                XCTFail("Signup should succeed")
            }
        }
    }
    
    func testThatLogInReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameters = LogInParameters(username: user.username, password: "")
        usersWebService.logIn(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Signup should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatGetUserReturnsUserIfSucceess() {
        urlSessionInterface.expectedEntity = user
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        usersWebService.get(user.id).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.id, self.user.id)
            case .failure:
                XCTFail("Get user should succeed")
            }
        }
    }
    
    func testThatGetUserReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        usersWebService.get(user.id).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Get user should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatUpdateUserReturnsUserIfSuccess() {
        urlSessionInterface.expectedEntity = user
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameter = UpdateUserParameters(id: user.id, firstName: user.firstName, lastName: user.lastName, email: user.email)
        usersWebService.update(parameter).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.id, self.user.id)
            case .failure:
                XCTFail("Update user should succeed")
            }
        }
    }
    
    func testThatUpdateUserReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameter = UpdateUserParameters(id: user.id, firstName: user.firstName, lastName: user.lastName, email: user.email)
        usersWebService.update(parameter).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Update user should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatSearchUsersReturnsUsersIfSuccess() {
        urlSessionInterface.expectedEntity = [user]
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        usersWebService.search("sh").waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.count, 1)
                XCTAssertEqual(entity.first?.id, self.user.id)
            case .failure:
                XCTFail("Search users should succeed")
            }
        }
    }
    
    func testThatSearchUsersReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        usersWebService.search("sh").waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Search users should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
}
