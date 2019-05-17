import XCTest
@testable import libra_ios

class RecordsStorageTests: XCTestCase {
    let record = Record(id: 999, title: "Good event", note: "There is something good", date: Date(), amount: 100, currency: .usd, mood: .good, companions: [ Person(id: 999, username: "shengwu", firstName: "Sheng", lastName: "Wu", email: "shengwu@libra.co")])
    var recordsStorage: RecordsStorage!
    
    override func setUp() {
        super.setUp()
        
        recordsStorage = RecordsStorage()
    }

    override func tearDown() {
        super.tearDown()
        
        recordsStorage = nil
    }
    
    func testThatFetchReturnsRecordsIfRecordsAreSaved() throws {
        try recordsStorage.save([record])
        
        let result = try recordsStorage.fetch()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, record.id)
        
        try recordsStorage.delete()
    }
    
    func testThatFetchThrowsPersistingErrorIfRecordsAreDeleted() {
        do {
            try recordsStorage.delete()
            _ = try recordsStorage.fetch()
            XCTFail("The records have been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
    
    func testThatFetchChangingActionsReturnsChangingActionsIfChangingActionsAreSaved() throws {
        let changingAction = ChangingAction.update(oldValue: record, newValue: record)
        try recordsStorage.saveChangingActions([changingAction])
        
        let result = try recordsStorage.fetchChangingActions()
        XCTAssertEqual(result.count, 1)
        guard let first = result.first, case let .update(old, new) = first else {
            return XCTFail("The first result should be an update action")
        }
        XCTAssertEqual(old.id, record.id)
        XCTAssertEqual(new.id, record.id)
        
        try recordsStorage.deleteChangingActions()
    }
    
    func testThatFetchChangingActionsThrowsPersistingErrorIfChangingActionsAreDeleted() {
        do {
            try recordsStorage.deleteChangingActions()
            _ = try recordsStorage.fetchChangingActions()
            XCTFail("The changing actions have been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
}
