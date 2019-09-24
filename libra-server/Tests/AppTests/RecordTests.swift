@testable import App
import Vapor
import FluentPostgreSQL
import XCTest

final class RecordTests: XCTestCase {
    var app: Application!
    var conn: PostgreSQLConnection!
    
    override func setUp() {
        super.setUp()
        
        try! Application.reset() // Reset database
        
        app = try! Application.testable()
        conn = try! app.newConnection(to: .psql).wait()
    }
    
    override func tearDown() {
        super.tearDown()
        
        conn.close()
        try! app.syncShutdownGracefully() // This is necessary to resolve the too many thread usages
    }
    
    func testThatGetAllRecordsSucceeds() throws {
        let (user, token, _, record, attachment) = try seedDataIncludingRecord()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getAllRecordsResponse = try app.sendRequest(to: "api/v1/records", method: .GET, headers: headers, body: EmptyBody())
        let receivedRecords = try getAllRecordsResponse.content.decode([Record.Intact].self).wait()
        
        XCTAssertEqual(receivedRecords.count, 1)
        XCTAssertEqual(receivedRecords.first?.id, record.id)
        XCTAssertEqual(receivedRecords.first?.title, record.title)
        XCTAssertEqual(receivedRecords.first?.note, record.note)
        
        // TODO: Investigate why this doesn't work
//        XCTAssertEqual(receivedRecords.first?.date, record.date)
        XCTAssertEqual(receivedRecords.first?.amount, record.amount)
        XCTAssertEqual(receivedRecords.first?.currency, record.currency)
        XCTAssertEqual(receivedRecords.first?.mood, record.mood)
        XCTAssertEqual(receivedRecords.first?.creator.id, user.id)
        XCTAssertEqual(receivedRecords.first?.assets.count, 1)
        XCTAssertEqual(receivedRecords.first?.assets.first?.id, attachment.id)
    }
    
    func testThatGetAllRecordsSucceedsWithEmptyResponse() throws {
        let (_, token, _) = try seedDataWithoutRecord()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getAllRecordsResponse = try app.sendRequest(to: "api/v1/records", method: .GET, headers: headers, body: EmptyBody())
        let receivedRecords = try getAllRecordsResponse.content.decode([Record.Intact].self).wait()
        
        XCTAssertEqual(getAllRecordsResponse.http.status, .ok)
        XCTAssertEqual(receivedRecords.count, 0)
    }
    
    func testThatGetAllRecordsSucceedsWithEmptyResponseIfRecordIsDeleted() throws {
        let (_, token, _, _, _) = try seedDataIncludingRecord(isDeleted: true)
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getAllRecordsResponse = try app.sendRequest(to: "api/v1/records", method: .GET, headers: headers, body: EmptyBody())
        let receivedRecords = try getAllRecordsResponse.content.decode([Record.Intact].self).wait()
        
        XCTAssertEqual(getAllRecordsResponse.http.status, .ok)
        XCTAssertEqual(receivedRecords.count, 0)
    }
    
    func testThatGetAllRecordsThrowsUnauthorizedIfTokenIsWrong() throws {        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let getAllRecordsResponse = try app.sendRequest(to: "api/v1/records", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getAllRecordsResponse.http.status, .unauthorized)
    }
    
    func testThatGetOneRecordSucceeds() throws {
        let (user, token, _, record, attachment) = try seedDataIncludingRecord()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getOneRecordResponse = try app.sendRequest(to: "api/v1/records/\(record.requireID())", method: .GET, headers: headers, body: EmptyBody())
        let receivedRecord = try getOneRecordResponse.content.decode(Record.Intact.self).wait()
        
        XCTAssertEqual(receivedRecord.id, record.id)
        XCTAssertEqual(receivedRecord.title, record.title)
        XCTAssertEqual(receivedRecord.note, record.note)
        
        // TODO: Investigate why thist work
        //        XCTAssertEqual(receivedReceord.date, record.date)
        XCTAssertEqual(receivedRecord.amount, record.amount)
        XCTAssertEqual(receivedRecord.currency, record.currency)
        XCTAssertEqual(receivedRecord.mood, record.mood)
        XCTAssertEqual(receivedRecord.creator.id, user.id)
        XCTAssertEqual(receivedRecord.assets.count, 1)
        XCTAssertEqual(receivedRecord.assets.first?.id, attachment.id)
    }
    
    func testThatGetOneRecordThrowsUnauthorizedIfTokenIsWrong() throws {
        let (_, _, _, record, _) = try seedDataIncludingRecord()

        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let getOneRecordResponse = try app.sendRequest(to: "api/v1/records/\(record.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneRecordResponse.http.status, .unauthorized)
    }
    
    func testThatGetOneRecordThrowsNotFoundIfRecordDoesNotExist() throws {
        let (_, token, _) = try seedDataWithoutRecord()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getOneRecordResponse = try app.sendRequest(to: "api/v1/records/999", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneRecordResponse.http.status, .notFound)
    }
    
    func testThatGetOneRecordThrowsUnauthorizedIfUserCannotAccessResource() throws {
        let (_, _, _, record, _) = try seedDataIncludingRecord()
        let (_, anotherToken, _) = try seedDataWithoutRecord(username: "sheng1")
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: anotherToken.token)
        let getOneRecordResponse = try app.sendRequest(to: "api/v1/records/\(record.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneRecordResponse.http.status, .unauthorized)
    }
    
    func testThatGetOneRecordThrowsNotFoundIfRecordIsDeleted() throws {
        let (_, token, _, record, _) = try seedDataIncludingRecord(isDeleted: true)
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let getOneRecordResponse = try app.sendRequest(to: "api/v1/records/\(record.requireID())", method: .GET, headers: headers, body: EmptyBody())
        
        XCTAssertEqual(getOneRecordResponse.http.status, .notFound)
    }
    
    func testThatCreateRecordSucceeds() throws {
        let (user, token, _) = try seedDataWithoutRecord()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = Record.RequestBody(title: "First Record", note: "this is a record", date: Date(), amount: 999, currency: "usd", mood: "good", companionIDs: [])
        let createRecordResponse = try app.sendRequest(to: "api/v1/records", method: .POST, headers: headers, body: body, bodyEncoder: .custom(dates: .millisecondsSince1970))
        let receivedRecord = try createRecordResponse.content.decode(Record.Intact.self).wait()
        
        XCTAssertNotNil(receivedRecord.id)
        XCTAssertEqual(receivedRecord.title, body.title)
        XCTAssertEqual(receivedRecord.note, body.note)
        
        // TODO: Investigate why thist work
        //        XCTAssertEqual(receivedReceord.date, body.date)
        XCTAssertEqual(receivedRecord.amount, body.amount)
        XCTAssertEqual(receivedRecord.currency, body.currency)
        XCTAssertEqual(receivedRecord.mood, body.mood)
        XCTAssertEqual(receivedRecord.creator.id, user.id)
        XCTAssertEqual(receivedRecord.assets.count, 0)
        XCTAssertEqual(receivedRecord.companions.count, 0)
    }
    
    func testThatCreateRecordThrowsUnauthorizedIfTokenIsWrong() throws {
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let body = Record.RequestBody(title: "First Record", note: "this is a record", date: Date(), amount: 999, currency: "usd", mood: "good", companionIDs: [])
        let createRecordResponse = try app.sendRequest(to: "api/v1/records", method: .POST, headers: headers, body: body, bodyEncoder: .custom(dates:
            .millisecondsSince1970))
        
        XCTAssertEqual(createRecordResponse.http.status, .unauthorized)
    }
    
    func testThatUpdateRecordSucceeds() throws {
        let (user, token, _, record, attachment) = try seedDataIncludingRecord()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: token.token)
        let body = Record.RequestBody(title: "New Title", note: "New Note", date: Date(), amount: 1999, currency: "euro", mood: "bad", companionIDs: [])
        let updateRecordResponse = try app.sendRequest(to: "api/v1/records/\(record.requireID())", method: .PUT, headers: headers, body: body, bodyEncoder: .custom(dates: .millisecondsSince1970))
        let receivedRecord = try updateRecordResponse.content.decode(Record.Intact.self).wait()
        
        XCTAssertNotNil(receivedRecord.id)
        XCTAssertEqual(receivedRecord.title, body.title)
        XCTAssertEqual(receivedRecord.note, body.note)
        
        // TODO: Investigate why thist work
        //        XCTAssertEqual(receivedReceord.date, body.date)
        XCTAssertEqual(receivedRecord.amount, body.amount)
        XCTAssertEqual(receivedRecord.currency, body.currency)
        XCTAssertEqual(receivedRecord.mood, body.mood)
        XCTAssertEqual(receivedRecord.creator.id, user.id)
        XCTAssertEqual(receivedRecord.assets.count, 1)
        XCTAssertEqual(receivedRecord.assets.first?.id, attachment.id)
        XCTAssertEqual(receivedRecord.companions.count, 0)
    }
    
    func testThatUpdateRecordThrowsUnauthorizedIfTokenIsWrong() throws {
        let (_, _, _, record, _) = try seedDataIncludingRecord()
        
        var headers = HTTPHeaders()
        headers.bearerAuthorization = BearerAuthorization(token: "XYZ")
        let body = Record.RequestBody(title: "New Title", note: "New Note", date: Date(), amount: 1999, currency: "euro", mood: "bad", companionIDs: [])
        let updateRecordResponse = try app.sendRequest(to: "api/v1/records/\(record.requireID())", method: .PUT, headers: headers, body: body, bodyEncoder: .custom(dates: .millisecondsSince1970))
        
        XCTAssertEqual(updateRecordResponse.http.status, .unauthorized)
    }
}

// MARK: - Private
private extension RecordTests {
    // TODO: Clean up with randomness
    func seedDataWithoutRecord(username: String = "sheng") throws -> (User, Token, Avatar) {
        let user = try User(firstName: "sheng", lastName: "wu", username: username, password: "12345678", email: "\(username)@libra.co").encryptPassword().save(on: conn).wait()
        let token = try Token(token: "4rfv5t\(username)gb6yhn==", isRevoked: false, osName: "mac os", timeZone: "CEST", userID: user.requireID()).save(on: conn).wait() // token should be different from user to user
        let avatar = try Avatar(name: "XYZ", userID: user.requireID()).save(on: conn).wait()
        
        return (user, token, avatar)
    }
    
    func seedDataIncludingRecord(isDeleted: Bool = false) throws -> (User, Token, Avatar, Record, Attachment) {
        let (user, token, avatar) = try seedDataWithoutRecord()
        let record = try Record(title: "First Record", note: "This is my first record", date: Date(), currency: "usd", mood: "good", isDeleted: isDeleted, creatorID: user.requireID()).save(on: conn).wait()
        let attachment = try Attachment(name: "ABC", recordID: record.requireID()).save(on: conn).wait()
        
        return (user, token, avatar, record, attachment)
    }
}
