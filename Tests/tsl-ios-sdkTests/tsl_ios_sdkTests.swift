import XCTest
@testable import tsl_ios_sdk

final class tsl_ios_sdkTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testPubNubConfiguration() {
        // Arrange
        let pubnubHandler = PubNubHandler.shared
        let expectation = self.expectation(description: "Fetching Auth Key")
                
        // Act
        pubnubHandler.fetchAuthKey { authKey in
            // Assert
            print("Test auth key", authKey)
            expectation.fulfill()
        }
        print(pubnubHandler)
        
        // Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 5, handler: nil)
    }
}
