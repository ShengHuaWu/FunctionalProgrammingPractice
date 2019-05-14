import XCTest
@testable import libra_ios

class UserStorageTests: XCTestCase {
    let user = User(person: Person(id: 999, username: "shengwu", firstName: "Sheng", lastName: "Wu", email: "shengwu@libra.co"), token: "123456789")
    var userStorage: UserStorage!
    
    override func setUp() {
        super.setUp()
        
        userStorage = UserStorage()
    }

    override func tearDown() {
        super.tearDown()
        
        userStorage = nil
    }

    func testThatFetchReturnsUserIfUserIsSaved() throws {
        try userStorage.save(user)
        
        let result = try userStorage.fetch()
        XCTAssertEqual(result.person.id, user.person.id)
        XCTAssertNil(result.token) // Token should NOT be saved
        
        try userStorage.delete()
    }
    
    func testThatFetchThrowsPersistingErrorIfUserIsDeleted() {
        do {
            try userStorage.delete()
            _ = try userStorage.fetch()
            XCTFail("The string has been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
}
