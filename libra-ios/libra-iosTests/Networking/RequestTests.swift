import XCTest
@testable import libra_ios

struct FakeModel: Codable {
    let name: String
    let date: Date
}

struct FakeParameters: Encodable {
    let value: String
    let date: Date
}

class RequestTests: XCTestCase {
    let baseURL = URL(string: "https://libra.co")!
    let generalHeader = ["Content-Type": "application/json"]
    
    // Use an integer for time intervals to avoid encoding truncation
    let model = FakeModel(name: "libra", date: Date(timeIntervalSince1970: 579088355))
    let parameters = FakeParameters(value: "libra", date: Date(timeIntervalSince1970: 579088355))
    
    func testThatMakeGetRequest() throws {
        let method = HTTPMethod.get
        let request = Request<FakeModel>.init(url: baseURL, method: method, headers: generalHeader, dateDecodingStrategy: .iso8601)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        XCTAssertNil(request.urlRequest.httpBody)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
        XCTAssertEqual(result.date, model.date)
    }
    
    func testThatMakePostRequest() throws {
        let method = HTTPMethod.post
        let request = Request<FakeModel>(url: baseURL, method: method, bodyParameters: parameters, dateEncodingStrategy: .millisecondsSince1970, headers: generalHeader, dateDecodingStrategy: .iso8601)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        XCTAssertEqual(request.urlRequest.httpBody, try encoder.encode(parameters))
        
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
        XCTAssertEqual(result.date, model.date)
    }
    
    func testThatMakePutRequest() throws {
        let method = HTTPMethod.put
        let request = Request<FakeModel>(url: baseURL, method: method, bodyParameters: parameters, dateEncodingStrategy: .millisecondsSince1970, headers: generalHeader, dateDecodingStrategy: .iso8601)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        XCTAssertEqual(request.urlRequest.httpBody, try encoder.encode(parameters))
        
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
        XCTAssertEqual(result.date, model.date)
    }
    
    func testThatMakeDeleteRequest() throws {
        let method = HTTPMethod.delete
        let request = Request<FakeModel>.init(url: baseURL, method: method, headers: generalHeader, dateDecodingStrategy: .iso8601)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        XCTAssertNil(request.urlRequest.httpBody)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
        XCTAssertEqual(result.date, model.date)
    }
}
