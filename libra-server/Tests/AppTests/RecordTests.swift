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
}
