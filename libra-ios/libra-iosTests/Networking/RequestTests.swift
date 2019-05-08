import XCTest
@testable import libra_ios

struct FakeModel: Codable {
    let name: String
}

struct FakeParameter: Encodable {
    let value: String
}

// TODO: Test encoding & decoding date strategies
class RequestTests: XCTestCase {
    let baseURL = URL(string: "https://libra.co")!
    let generalHeader = ["Content-Type": "application/json"]
    let model = FakeModel(name: "libra")
    
    func testThatMakeGetRequest() throws {
        let method = HTTPMethod.get
        let request = Request<FakeModel>.init(url: baseURL, method: method, headers: generalHeader, dateDecodingStrategy: nil)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        XCTAssertNil(request.urlRequest.httpBody)
        
        let data = try JSONEncoder().encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
    }
    
    func testThatMakePostRequest() throws {
        let method = HTTPMethod.post
        let parameter = FakeParameter(value: "libra-ios")
        let request = Request<FakeModel>(url: baseURL, method: method, bodyParameters: parameter, dateEncodingStrategy: nil, headers: generalHeader, dateDecodingStrategy: nil)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        XCTAssertEqual(request.urlRequest.httpBody, try JSONEncoder().encode(parameter))
        
        let data = try JSONEncoder().encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
    }
    
    func testThatMakePutRequest() throws {
        let method = HTTPMethod.put
        let parameter = FakeParameter(value: "libra-ios")
        let request = Request<FakeModel>(url: baseURL, method: method, bodyParameters: parameter, dateEncodingStrategy: nil, headers: generalHeader, dateDecodingStrategy: nil)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        XCTAssertEqual(request.urlRequest.httpBody, try JSONEncoder().encode(parameter))
        
        let data = try JSONEncoder().encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
    }
    
    func testThatMakeDeleteRequest() throws {
        let method = HTTPMethod.delete
        let request = Request<FakeModel>.init(url: baseURL, method: method, headers: generalHeader, dateDecodingStrategy: nil)
        XCTAssertEqual(request.urlRequest.url, baseURL)
        XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
        XCTAssertNil(request.urlRequest.httpBody)
        
        let data = try JSONEncoder().encode(model)
        let result = try request.parse(data)
        XCTAssertEqual(result.name, model.name)
    }
}
