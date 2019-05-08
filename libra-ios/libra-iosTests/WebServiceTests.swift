import XCTest
@testable import libra_ios

// TODO: Separate user & record tests into different files
class WebServiceTests: XCTestCase {
    var webService: WebService!
    var urlSessionInterface: MockURLSessionInterface!
    let user = User(id: 999, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co", token: "987654321")
    let record = Record(id: 999, title: "Libra Record", note: "This is just one record", date: Date(), amount: 100, currency: .usd, mood: .good, companions: [Companion(id: 999, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co")])

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
    
    func testThatSignUpReturnsUserIfSuccess() {
        urlSessionInterface.expectedEntity = user
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameter = SignUpParameters(username: user.username, password: "", firstName: user.firstName, lastName: user.lastName  , email: user.email)
        webService.signUp(parameter).waitAndAssert(on: self) { result in
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
        webService.signUp(parameter).waitAndAssert(on: self) { result in
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
        
        let parameters = LoginParameters(username: user.username, password: "")
        webService.logIn(parameters).waitAndAssert(on: self) { result in
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
        
        let parameters = LoginParameters(username: user.username, password: "")
        webService.logIn(parameters).waitAndAssert(on: self) { result in
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
        
        webService.getUser(user.id).waitAndAssert(on: self) { result in
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
        
        webService.getUser(user.id).waitAndAssert(on: self) { result in
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
        webService.updateUser(parameter).waitAndAssert(on: self) { result in
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
        webService.updateUser(parameter).waitAndAssert(on: self) { result in
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
    
    func testThatGetRecordsReturnsRecordsIfSuccess() {
        urlSessionInterface.expectedEntity = [record]
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.getRecords().waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.count, 1)
                XCTAssertEqual(entity.first?.id, self.record.id)
            case .failure:
                XCTFail("Get records should succeed")
            }
        }
    }
    
    func testThatGetRecordsReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.getRecords().waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Get records should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatGetRecordReturnsRecordIfSuccess() {
        urlSessionInterface.expectedEntity = record
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.getRecord(999).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.id, self.record.id)
            case .failure:
                XCTFail("Get record should succeed")
            }
        }
    }
    
    func testThatGetRecordReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.getRecord(999).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Get record should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatCreateRecordReturnsRecordIfSuccess() {
        urlSessionInterface.expectedEntity = record
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = CreateOrUpdateRecordParameters(id: nil, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions ?? [])
        webService.createRecord(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.id, self.record.id)
            case .failure:
                XCTFail("Create record should succeed")
            }
        }
    }
    
    func testThatCreateRecordReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = CreateOrUpdateRecordParameters(id: nil, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions ?? [])
        webService.createRecord(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Create record should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatUpdateRecordReturnsRecordIfSuccess() {
        urlSessionInterface.expectedEntity = record
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = CreateOrUpdateRecordParameters(id: 999, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions ?? [])
        webService.updateRecord(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(entity.id, self.record.id)
            case .failure:
                XCTFail("Update record should succeed")
            }
        }
    }
    
    func testThatUpdateRecordReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = CreateOrUpdateRecordParameters(id: 999, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions ?? [])
        webService.updateRecord(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Update record should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
    
    func testThatDeleteRecordReturnsSuccessResponseIfSuccess() {
        urlSessionInterface.expectedEntity = SuccessResponse()
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.deleteRecord(999).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(fetchTokenCallCount, 1)
                XCTAssertTrue(entity.success)
            case .failure:
                XCTFail("Delete record should succeed")
            }
        }
    }
    
    func testThatDeleteRecordReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        webService.deleteRecord(999).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Delete record should fail")
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
        
        webService.searchUsers("sh").waitAndAssert(on: self) { result in
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
        
        webService.searchUsers("sh").waitAndAssert(on: self) { result in
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
        
        let parameters = AddFriendshipParameters(userID: user.id, personID: user.id)
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
        
        let parameters = AddFriendshipParameters(userID: user.id, personID: user.id)
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
        
        let parameters = GetFriendParameters(userID: user.id, friendID: user.id)
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
        
        let parameters = GetFriendParameters(userID: user.id, friendID: user.id)
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
        
        let parameters = RemoveFriendshipParameters(userID: user.id, friendID: user.id)
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
        
        let parameters = RemoveFriendshipParameters(userID: user.id, friendID: user.id)
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
