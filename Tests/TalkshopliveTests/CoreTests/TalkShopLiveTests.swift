import XCTest
@testable import Talkshoplive

final class TalkShopLiveTests: XCTestCase {
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
        let clientKey = "0GmN76SBDdHRsGLRDcmVzpURj"
        
        // Use XCTest expectations to wait for asynchronous operations
        let initializationExpectation = expectation(description: "TalkShopLive initialization with valid client key")
        
        _ = TalkShopLive(clientKey: clientKey,testMode: true) { result in
            switch result {
            case .success:
                // Test passed
                initializationExpectation.fulfill()
            case .failure(let error):
                initializationExpectation.fulfill()
                XCTFail("Initialization should not fail with error: \(error)")
            }
        }
        
        // Wait for the expectation with a timeout
        waitForExpectations(timeout: 10, handler: nil)
        
        // Optionally, you can perform additional assertions on the created instance
    }
    
}
