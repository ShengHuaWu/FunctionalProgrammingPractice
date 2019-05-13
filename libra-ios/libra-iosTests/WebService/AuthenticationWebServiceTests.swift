import XCTest
@testable import libra_ios

class AuthenticationWebServiceTests: XCTestCase {
    var authenticationWebService: AuthenticationWebService!
    var urlSessionInterface: MockURLSessionInterface!
    let user = User(person: Person(id: 999, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co"), token: "987654321")

    override func setUp() {
        super.setUp()
        
        Current = .mock
        
        urlSessionInterface = MockURLSessionInterface()
        authenticationWebService = AuthenticationWebService()
    }

    override func tearDown() {
        super.tearDown()
        
        urlSessionInterface = nil
        authenticationWebService = nil
    }

    func testThatSignUpReturnsUserIfSuccess() {
        urlSessionInterface.expectedEntity = user
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameter = SignUpParameters(username: user.person.username, password: "", firstName: user.person.firstName, lastName: user.person.lastName  , email: user.person.email)
        authenticationWebService.signUp(parameter).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(entity.person.id, self.user.person.id)
            case .failure:
                XCTFail("Signup should succeed")
            }
        }
    }
    
    func testThatSignUpReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameter = SignUpParameters(username: user.person.username, password: "", firstName: user.person.firstName, lastName: user.person.lastName, email: user.person.email)
        authenticationWebService.signUp(parameter).waitAndAssert(on: self) { result in
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
        
        let parameters = LogInParameters(username: user.person.username, password: "")
        authenticationWebService.logIn(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success(let entity):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(entity.person.id, self.user.person.id)
            case .failure:
                XCTFail("Signup should succeed")
            }
        }
    }
    
    func testThatLogInReturnsNetworkErrorIfFailure() {
        urlSessionInterface.expectedError = .badRequest
        Current.urlSession = { return self.urlSessionInterface }
        
        let parameters = LogInParameters(username: user.person.username, password: "")
        authenticationWebService.logIn(parameters).waitAndAssert(on: self) { result in
            switch result {
            case .success:
                XCTFail("Signup should fail")
            case .failure(let error):
                XCTAssertEqual(self.urlSessionInterface.sendCallCount, 1)
                XCTAssertEqual(error, .badRequest)
            }
        }
    }
}
