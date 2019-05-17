import XCTest
@testable import libra_ios

class FriendsStorageTests: XCTestCase {
    let friend =  Person(id: 999, username: "shengwu", firstName: "Sheng", lastName: "Wu", email: "shengwu@libra.co")
    var friendsStorage: FriendsStorage!
    
    override func setUp() {
        super.setUp()
        
        friendsStorage = FriendsStorage()
    }

    override func tearDown() {
        super.tearDown()
        
        friendsStorage = nil
    }
    
    func testThatFetchReturnsFriendsIfFriendsAreSaved() throws {
        try friendsStorage.save([friend])
        
        let result = try friendsStorage.fetch()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, friend.id)
        
        try friendsStorage.delete()
    }
    
    func testThatFetchThrowsPersistingErrorIfFriendsAreDeleted() {
        do {
            try friendsStorage.delete()
            _ = try friendsStorage.fetch()
            XCTFail("The friends have been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
    
    func testThatFetchChangingActionsReturnsChangingActionsIfChangingActionsAreSaved() throws {
        let changingAction = ChangingAction.update(oldValue: friend, newValue: friend)
        try friendsStorage.saveChangingActions([changingAction])
        
        let result = try friendsStorage.fetchChangingActions()
        XCTAssertEqual(result.count, 1)
        guard let first = result.first, case let .update(old, new) = first else {
            return XCTFail("The first result should be an update action")
        }
        XCTAssertEqual(old.id, friend.id)
        XCTAssertEqual(new.id, friend.id)
        
        try friendsStorage.deleteChangingActions()
    }
    
    func testThatFetchChangingActionsThrowsPersistingErrorIfChangingActionsAreDeleted() {
        do {
            try friendsStorage.deleteChangingActions()
            _ = try friendsStorage.fetchChangingActions()
            XCTFail("The changing actions have been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
}
