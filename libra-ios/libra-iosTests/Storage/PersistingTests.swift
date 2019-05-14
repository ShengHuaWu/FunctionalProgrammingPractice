import XCTest
@testable import libra_ios

struct FakeEntity: Codable {
    let id: Int
    let name: String
    let date: Date
}

class PersistingTests: XCTestCase {
    let key = "This is a key"
    let string = "This is a string"
    let entity = FakeEntity(id: 999, name: "Sheng Wu", date: Date())
    
    func testThatFetchStringReturnsStringIfStringIsSaved() throws {
        let persisting = Persisting<String, String>.userDefaults
        try persisting.save(string, key)
        
        let result = try persisting.fetch(key)
        XCTAssertEqual(result, string)
        
        try persisting.delete(key)
    }
    
    func testThatFetchStringThrowsPersistingErrorIfStringIsDeleted() {
        let persisting = Persisting<String, String>.userDefaults
        
        do {
            try persisting.delete(key)
            _ = try persisting.fetch(key)
            XCTFail("The string has been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
    
    func testThatFetchEntityReturnsEntityIfEnityIsSaved() throws {
        let persisting = Persisting<String, FakeEntity>.userDefaults
        try persisting.save(entity, key)
        
        let result = try persisting.fetch(key)
        XCTAssertEqual(result.id, entity.id)
        XCTAssertEqual(result.name, entity.name)
        XCTAssertEqual(result.date, entity.date)
        
        try persisting.delete(key)
    }
    
    func testThatFetchEntityThrowsPersistingErrorIfEntityIsDeleted() {
        let persisting: Persisting<String, FakeEntity> = Persisting.userDefaults
        
        do {
            try persisting.delete(key)
            _ = try persisting.fetch(key)
            XCTFail("The entity has been deleted already")
        } catch PersistingError.noEntity {
            
        } catch {
            XCTFail("The error should be no entity")
        }
    }
}
