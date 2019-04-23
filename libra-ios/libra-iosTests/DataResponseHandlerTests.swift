import XCTest
@testable import libra_ios

enum FakeError: Error {
    case fake
}

extension URLResponse {
    static func makeFake() -> URLResponse {
        return URLResponse(url: URL(string: "https://libra.co")!, mimeType: nil, expectedContentLength: -999, textEncodingName: nil)
    }
}

extension HTTPURLResponse {
    static func makeFake(with statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://libra.co")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

// This test case ensures the order of function composition
class DataResponseHandlerTests: XCTestCase {
    var handler: DataTaskResponseHandler!
    let errorResponse = ErrorResponse(error: true, reason: "An error occurs")
    let successResponse = SuccessResponse()
    
    override func setUp() {
        super.setUp()
        
        handler = DataTaskResponseHandler()
    }
    
    override func tearDown() {
        super.tearDown()
        
        handler = nil
    }
    
    func testThatUnwrapDataThrowsFailureIfErrorExists() {
        let fakeError = FakeError.fake
        do {
            _ = try handler.unwrapData(try! JSONEncoder().encode(errorResponse), HTTPURLResponse.makeFake(with: 200), fakeError)
            XCTFail("Error should be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .failure(mesage: fakeError.localizedDescription))
        } catch {
            XCTFail("Error should be a network error")
        }
    }
    
    func testThatUnwrapDataThrowsClientErrorIfErrorResponseExists() {
        do {
            _ = try handler.unwrapData(try! JSONEncoder().encode(errorResponse), HTTPURLResponse.makeFake(with: 200), nil)
            XCTFail("Error should be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .clientError(reason: errorResponse.reason))
        } catch {
            XCTFail("Error should be a network error")
        }
    }
    
    func testThatUnwrapDataThrowsUnexpectedResponseIfURLResponseIsNotHTTPURLResponse() {
        do {
            _ = try handler.unwrapData(try! JSONEncoder().encode(successResponse), URLResponse.makeFake(), nil)
            XCTFail("Error should be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unexpectedResponse)
        } catch {
            XCTFail("Error should be a network error")
        }
    }
    
    func testThatUnwrapDataThrowsDifferentErrorsIfStatusCodeIsInBetween400And499() {
        (400 ... 499).forEach { code in
            do {
                _ = try handler.unwrapData(try! JSONEncoder().encode(successResponse), HTTPURLResponse.makeFake(with: code), nil)
                XCTFail("Error should be thrown")
            } catch let error as NetworkError {
                switch code {
                case 400:
                    XCTAssertEqual(error, .badRequest)
                case 401:
                    XCTAssertEqual(error, .unauthorized)
                case 403:
                    XCTAssertEqual(error, .forbidden)
                case 404:
                    XCTAssertEqual(error, .notFound)
                default:
                    XCTAssertEqual(error, .clientError(reason: nil))
                }
                
            } catch {
                XCTFail("Error should be a network error")
            }
        }
    }
    
    func testThatUnwrapDataThrowsServerErrorIfStatusCodeIsInBetween500And599() {
        (500 ... 599).forEach { code in
            do {
                _ = try handler.unwrapData(try! JSONEncoder().encode(successResponse), HTTPURLResponse.makeFake(with: code), nil)
                XCTFail("Error should be thrown")
            } catch let error as NetworkError {
                XCTAssertEqual(error, .serverError)
            } catch {
                XCTFail("Error should be a network error")
            }
        }
    }
    
    func testThatUnwrapDataReturnsSuccessResponseIfDataIsEmpty() throws {
        let data = try handler.unwrapData(nil, HTTPURLResponse.makeFake(with: 200), nil)
        let successResponse = try JSONDecoder().decode(SuccessResponse.self, from: data)
        XCTAssertTrue(successResponse.success)
    }
}
