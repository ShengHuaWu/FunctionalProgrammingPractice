import XCTest
@testable import libra_ios

class AuthenticationStorageTests: XCTestCase {
    let token = "This is a token"    
    var authenticationStorage: AuthenticationStorage!
    
    override func setUp() {
        super.setUp()
        
        authenticationStorage = AuthenticationStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        
        authenticationStorage = nil
    }
    
    func testThatFetchTokenReturnsTokenIfTokenIsSaved() throws {
        try authenticationStorage.saveToken(token)
        
        XCTAssertEqual(try authenticationStorage.fetchToken(), token)
        
        try authenticationStorage.deleteToken()
    }
    
    func testThatFetchTokenThrowsPersistingErrorIfTokenIsDeleted() {
        do {
            try authenticationStorage.deleteToken()
            _ = try authenticationStorage.fetchToken()
            XCTFail("The string has been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
}
