import XCTest
@testable import TalkShopLive

final class TalkShopLiveSDKTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest
        
        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // Test initialization
    func testInitializeSDK() {
        let clientKey = "sdk_2ea21de19cc8bc5e8640c7b227fef2f3"
        
        // Use XCTest expectations to wait for asynchronous operations
        let initializationExpectation = expectation(description: "TalkShopLive initialization with valid client key")
        
        let talkShopLive = TalkShopLiveSDK(clientKey: clientKey,testMode: true) { result in
            switch result {
            case .success:
                // Test passed
                initializationExpectation.fulfill()
            case .failure(let error):
                XCTFail("Initialization should not fail with error: \(error)")
            }
        }
        
        // Wait for the expectation with a timeout
        waitForExpectations(timeout: 10, handler: nil)
        
        // Optionally, you can perform additional assertions on the created instance
        XCTAssertTrue(talkShopLive.testMode)
        XCTAssertTrue(Config.shared.isInitialized())
        XCTAssertFalse(talkShopLive.dnt)
    }
    
}
