import XCTest
@testable import libra_ios

class RecordsWebServiceTests: XCTestCase {
    var recordsWebService: RecordsWebService!
    var urlSessionInterface: MockURLSessionInterface!
    let record = Record(id: 999, title: "Libra Record", note: "This is just one record", date: Date(), amount: 100, currency: .usd, mood: .good, companions: [Person(id: 999, username: "shengwu", firstName: "sheng", lastName: "wu", email: "shengwu@libra.co")])
    
    override func setUp() {
        super.setUp()
        
        Current = .mock
        
        urlSessionInterface = MockURLSessionInterface()
        recordsWebService = RecordsWebService()
    }
    
    override func tearDown() {
        super.tearDown()
        
        urlSessionInterface = nil
        recordsWebService = nil
    }
    
    func testThatGetRecordsReturnsRecordsIfSuccess() {
        urlSessionInterface.expectedEntity = [record]
        Current.urlSession = { return self.urlSessionInterface }
        
        var fetchTokenCallCount = 0
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        recordsWebService.getAll().waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        recordsWebService.getAll().waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        recordsWebService.get(999).waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        recordsWebService.get(999).waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = RecordParameters(id: nil, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions)
        recordsWebService.create(parameters).waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = RecordParameters(id: nil, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions)
        recordsWebService.create(parameters).waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = RecordParameters(id: 999, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions)
        recordsWebService.update(parameters).waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        let parameters = RecordParameters(id: 999, title: record.title, note: record.note, date: record.date, mood: record.mood, amount: record.amount, currency: record.currency, companions: record.companions)
        recordsWebService.update(parameters).waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        recordsWebService.delete(999).waitAndAssert(on: self) { result in
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
        Current.storage.authentication.fetchToken = {
            fetchTokenCallCount += 1
            return "This is a token"
        }
        
        recordsWebService.delete(999).waitAndAssert(on: self) { result in
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
}
