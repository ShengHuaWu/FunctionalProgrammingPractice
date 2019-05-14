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
            XCTFail("The string has been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
}
