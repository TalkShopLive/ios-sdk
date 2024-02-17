//
//  ChatTests.swift
//  
//
//  Created by TalkShopLive on 2024-01-25.
//

import XCTest
import Talkshoplive

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
    
    func testCreateMessagingToken() {
        TalkShopLiveTests().testInitializeSDK()
        
        let chatProvider = ChatProvider()
        
        // Use XCTestExpectation to wait for the asynchronous call to complete
        let expectation = XCTestExpectation(description: "Token retrieval completion")
        
        // Assuming the token is set after retrieval
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertNotNil(chatProvider.getToken())
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, timeout after 5 seconds
        wait(for: [expectation], timeout: 10)
    }
    
    func testUnsubscribeChannel() {
        var chatInstance: ChatProvider? = ChatProvider()
        chatInstance = nil
    }

}
