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
        let (user, token, _, record, attachment) = try seedData()
        
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
}

// MARK: - Private
private extension RecordTests {
    // TODO: Clean up with randomness
    func seedData() throws -> (User, Token, Avatar, Record, Attachment) {
        let user = try User(firstName: "sheng", lastName: "wu", username: "sheng", password: "12345678", email: "sheng@libra.co").encryptPassword().save(on: conn).wait()
        let token = try Token(token: "4rfv5tgb6yhn==", isRevoked: false, osName: "mac os", timeZone: "CEST", userID: user.requireID()).save(on: conn).wait() // token should be different from user to user
        let avatar = try Avatar(name: "XYZ", userID: user.requireID()).save(on: conn).wait()
        let record = try Record(title: "First Record", note: "This is my first record", date: Date(), currency: "usd", mood: "good", isDeleted: false, creatorID: user.requireID()).save(on: conn).wait()
        let attachment = try Attachment(name: "ABC", recordID: record.requireID()).save(on: conn).wait()
        
        return (user, token, avatar, record, attachment)
    }
}
