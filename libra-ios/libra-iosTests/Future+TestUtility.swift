import XCTest
@testable import libra_ios

extension Future {
    func wait(on testCase: XCTestCase, description: String = #function, timeout: TimeInterval = 2, assert: @escaping (A) -> Void) {
        let testExpectation = testCase.expectation(description: description)
        
        run { a in
            assert(a)
            testExpectation.fulfill()
        }
        
        testCase.waitForExpectations(timeout: timeout)
    }
}
