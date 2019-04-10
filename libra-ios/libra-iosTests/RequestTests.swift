import XCTest
@testable import libra_ios

struct FakeModel: Codable {
    let name: String
}

struct FakeParameter: Encodable {
    let value: String
}

class RequestTests: XCTestCase {
    let baseURL = URL(string: "https://libra.co")!
    let generalHeader = ["Content-Type": "application/json"]
    let model = FakeModel(name: "libra")
    
    func testThatMakeGetRequest() {
        let method = HTTPMethod.get
        do {
            let request = try Request<FakeModel>.init(url: baseURL, method: method, headers: generalHeader)
            XCTAssertEqual(request.urlRequest.url, baseURL)
            XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
            XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
            XCTAssertNil(request.urlRequest.httpBody)
            
            let data = try JSONEncoder().encode(model)
            let result = try request.parse(data)
            XCTAssertEqual(result.name, model.name)
        } catch {
            XCTFail("Everything should succeed")
        }
    }
    
    func testThatMakePostRequest() {
        let method = HTTPMethod.post
        let parameter = FakeParameter(value: "libra-ios")
        do {
            let request = try Request<FakeModel>(url: baseURL, method: method, bodyParameter: parameter, headers: generalHeader)
            XCTAssertEqual(request.urlRequest.url, baseURL)
            XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
            XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
            XCTAssertEqual(request.urlRequest.httpBody, try JSONEncoder().encode(parameter))
            
            let data = try JSONEncoder().encode(model)
            let result = try request.parse(data)
            XCTAssertEqual(result.name, model.name)
        } catch {
            XCTFail("Everything should succeed")
        }
    }
    
    func testThatMakePutRequest() {
        let method = HTTPMethod.put
        let parameter = FakeParameter(value: "libra-ios")
        do {
            let request = try Request<FakeModel>(url: baseURL, method: method, bodyParameter: parameter, headers: generalHeader)
            XCTAssertEqual(request.urlRequest.url, baseURL)
            XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
            XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
            XCTAssertEqual(request.urlRequest.httpBody, try JSONEncoder().encode(parameter))
            
            let data = try JSONEncoder().encode(model)
            let result = try request.parse(data)
            XCTAssertEqual(result.name, model.name)
        } catch {
            XCTFail("Everything should succeed")
        }
    }
    
    func testThatMakeDeleteRequest() {
        let method = HTTPMethod.delete
        do {
            let request = try Request<FakeModel>.init(url: baseURL, method: method, headers: generalHeader)
            XCTAssertEqual(request.urlRequest.url, baseURL)
            XCTAssertEqual(request.urlRequest.httpMethod, method.rawValue)
            XCTAssertEqual(request.urlRequest.allHTTPHeaderFields, generalHeader)
            XCTAssertNil(request.urlRequest.httpBody)
            
            let data = try JSONEncoder().encode(model)
            let result = try request.parse(data)
            XCTAssertEqual(result.name, model.name)
        } catch {
            XCTFail("Everything should succeed")
        }
    }
}
