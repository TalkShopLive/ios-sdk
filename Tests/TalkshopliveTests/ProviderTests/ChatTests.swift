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
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCreateGuestUserToken() {
        TalkShopLiveTests().testInitializeSDK()
        
        //Testing token
        let jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzZGtfMmVhMjFkZTE5Y2M4YmM1ZTg2NDBjN2IyMjdmZWYyZjMiLCJleHAiOjE3MDkyNjc3NDYsImp0aSI6InRXaEJBd1NUbVhVNnp5UUsxNUV1eXk9PSJ9.hHFWaQU-8yMCnPTsI7ah5wapjLvwSwo2ZbuQNwPggfU"
        let chatProvider = ChatProvider(jwtToken: jwtToken, isGuest: true, showKey: "8WtAFFgRO1K0")
        
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
        
        let jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzZGtfMmVhMjFkZTE5Y2M4YmM1ZTg2NDBjN2IyMjdmZWYyZjMiLCJleHAiOjE3MDkzNTQxNDYsImp0aSI6InRXc3NBd1NUbVhVNnp5UUsxNUV1eXk9PSIsInVzZXIiOnsiaWQiOiIxMjMiLCJuYW1lIjoiTWF5dXJpIn19.QS99WYjbvh8l4RfN3-NsNz1X7ZGThbBZep3UoM8oSok"
        let chatProvider = ChatProvider(jwtToken: jwtToken, isGuest: false, showKey: "8WtAFFgRO1K0")
        
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

}
