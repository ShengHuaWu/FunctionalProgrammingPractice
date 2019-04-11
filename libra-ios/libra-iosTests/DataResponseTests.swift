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

class DataResponseTests: XCTestCase {
    func testThatSanitizeErrorThrowsFaliureIfErrorExits() {
        let fakeError = FakeError.fake
        let response = DataTaskResponse(data: nil, urlResponse: nil, error: fakeError)
        do {
            _ = try sanitizeError(for: response)
            XCTFail("Error should be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .failure(mesage: fakeError.localizedDescription))
        } catch {
            XCTFail("Error should be a network error")
        }
    }
    
    func testThatSanitizeDataThrowsClientErrorIfErrorResponseExists() {
        let errorResponse = ErrorResponse(error: true, reason: "An error occur")
        let data = try! JSONEncoder().encode(errorResponse)
        let response = DataTaskResponse(data: data, urlResponse: nil, error: nil)
        do {
            _ = try sanitizeData(for: response)
            XCTFail("Error should be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .clientError(reason: errorResponse.reason))
        } catch {
            XCTFail("Error should be a network error")
        }
    }
    
    func testThatSanitizeURLResponseThrowsUnexpectedResponseIfURLResponseIsNotHTTPURLResponse() {
        let urlResponse = URLResponse.makeFake()
        let response = DataTaskResponse(data: nil, urlResponse: urlResponse, error: nil)
        do {
            _ = try sanitizeURLResponse(for: response)
            XCTFail("Error should be thrown")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .unexpectedResponse)
        } catch {
            XCTFail("Error should be a network error")
        }
    }
    
    func testThatSanitizeURLResponseThrowsDifferentErrorsIfStatusCodeIsInBetween400And499() {
        (400 ... 499).forEach { code in
            let httpURLResponse = HTTPURLResponse.makeFake(with: code)
            let response = DataTaskResponse(data: nil, urlResponse: httpURLResponse, error: nil)
            do {
                _ = try sanitizeURLResponse(for: response)
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
    
    func testThatSanitizeURLResponseThrowsServerErrorIfStatusCodeIsInBetween500And599() {
        (500 ... 599).forEach { code in
            let httpURLResponse = HTTPURLResponse.makeFake(with: code)
            let response = DataTaskResponse(data: nil, urlResponse: httpURLResponse, error: nil)
            do {
                _ = try sanitizeURLResponse(for: response)
                XCTFail("Error should be thrown")
            } catch let error as NetworkError {
                XCTAssertEqual(error, .serverError)
            } catch {
                XCTFail("Error should be a network error")
            }
        }
    }
    
    func testThatUnwrapDataReturnsSuccessResponseIfDataIsEmpty() {
        let httpURLResponse = HTTPURLResponse.makeFake(with: 200)
        let response = DataTaskResponse(data: nil, urlResponse: httpURLResponse, error: nil)
        do {
            let data = try unwrapDataAfterSanitizing(for: response)
            let successResponse = try JSONDecoder().decode(SuccessResponse.self, from: data)
            XCTAssertTrue(successResponse.success)
        } catch {
            XCTFail("Everything should succeed")
        }
    }
}
