import XCTest
@testable import AppTests

XCTMain([
  testCase(UserTests.allTests),
  testCase(RecordTests.allTests)
])
