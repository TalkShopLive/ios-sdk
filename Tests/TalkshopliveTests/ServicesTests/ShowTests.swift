//
//  ShowTests.swift
//
//
//  Created by TalkShopLive on 2024-01-26.
//

import XCTest
@testable import Talkshoplive


final class ShowTests: XCTestCase {
    
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
    
    func testFetchShows() {
        
        // Given
        let showInstance = Show()
        let showId = "vzzg6tNu0qOv"
        
        // Create an expectation for the asynchronous code
        let expectation = XCTestExpectation(description: "Get shows expectation")
        
        // When
        showInstance.getDetails(showId: showId) { result in
            // Then
            switch result {
            case .success(let show):
                // Assert that the received show matches the expected values
                XCTAssertEqual(show.name, "synth height test")
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
            
            // Fulfill the expectation, indicating that the asynchronous code has completed
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, with a timeout of 5 seconds
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchCurrentEvent() {
        // Given
        let eventInstance = Show()
        let showId = "8WtAFFgRO1K0"
        
        // Create an expectation for the asynchronous code
        let expectation = XCTestExpectation(description: "Get Current Event expectation")
        
        // When
        eventInstance.getStatus(showKey: showId) { result in
            // Then
            switch result {
            case .success(let show):
                // Assert that the received show matches the expected values
                XCTAssertEqual(show.status, "live")
            case .failure(let error):
                XCTFail("Expected success, but got failure with error: \(error)")
            }
            
            // Fulfill the expectation, indicating that the asynchronous code has completed
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, with a timeout of 5 seconds
        wait(for: [expectation], timeout: 10.0)
    }
    
    
}
