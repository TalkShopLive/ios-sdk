//
//  ChatTests.swift
//  
//
//  Created by TalkShopLive on 2024-01-25.
//

import XCTest
import tsl_ios_sdk

final class ChatTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            _ = Chat(eventId: "event123", mode: "public", refresh: "manual")
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPubNubConfiguration() {
        // Arrange
        let expectation = self.expectation(description: "Fetching Auth Key")
        
        Networking.postMessagingToken(completion: { result in
            switch result {
            case .success(let token):
                // Token retrieval successful, pass it to the completion handler
                print("TOKEN", token)
                expectation.fulfill()
            case .failure(let error):
                // Handle token retrieval failure
                print(error.localizedDescription)
                break
            }
        })
        // Wait for the expectation to be fulfilled
        waitForExpectations(timeout: 10, handler: nil)
    }

}
