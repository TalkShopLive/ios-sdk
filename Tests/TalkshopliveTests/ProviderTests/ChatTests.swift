//
//  ChatTests.swift
//  
//
//  Created by TalkShopLive on 2024-01-25.
//

import XCTest
import Talkshoplive

final class ChatTests: XCTestCase {

    var jwtGuestToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzZGtfMmVhMjFkZTE5Y2M4YmM1ZTg2NDBjN2IyMjdmZWYyZjMiLCJleHAiOjE3MDkwNjczNzgsImp0aSI6InRXaHNkd1NUbVhDNnp5V0sxNUF1eXk9PSJ9.UZH_U4URIZRu4hYkptod1ql6NmTYVD9B1_g8fCM0z8E"
    var jwtUserToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzZGtfMmVhMjFkZTE5Y2M4YmM1ZTg2NDBjN2IyMjdmZWYyZjMiLCJleHAiOjE3MDkxODY0NTEsInVzZXIiOnsiaWQiOiJpbnRlcm5hbC1kZXYtdXNlciIsIm5hbWUiOiJNYXl1cmkifSwianRpIjoidFdoQkF3U1RtWGV3ZXp5V0sxNUF1eXk9PSJ9.E04iwjoRQ6UUL2Y7y1W6CRrQQIilQ2MiWzTp4tva76c"
    var showKey = "8WtAFFgRO1K0"
    
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
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCreateGuestUserToken() {
        TalkShopLiveTests().testInitializeSDK()
        
        //Testing token
        let chatProvider = ChatProvider(jwtToken: jwtGuestToken, isGuest: true, showKey: self.showKey)
        
        // Use XCTestExpectation to wait for the asynchronous call to complete
        let expectation = XCTestExpectation(description: "Token retrieval completion")
        
        // Assuming the token is set after retrieval
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertNotNil(chatProvider.getMessagingToken())
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, timeout after 5 seconds
        wait(for: [expectation], timeout: 10)
    }
    
    func testCreateFedaratedUserToken() {
        TalkShopLiveTests().testInitializeSDK()
        
        let chatProvider = ChatProvider(jwtToken: jwtUserToken, isGuest: false, showKey: self.showKey)
        
        // Use XCTestExpectation to wait for the asynchronous call to complete
        let expectation = XCTestExpectation(description: "Token retrieval completion")
        
        // Assuming the token is set after retrieval
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            XCTAssertNotNil(chatProvider.getMessagingToken())
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, timeout after 5 seconds
        wait(for: [expectation], timeout: 20)
    }
}
