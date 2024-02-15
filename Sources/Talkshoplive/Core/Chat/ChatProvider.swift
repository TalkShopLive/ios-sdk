//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

public class ChatProvider {
    
    private var pubnub: PubNub?
    private var config: EnvConfig
    private var token: String?
    private var refreshTimer: Timer?
    
    public init() {
        // Load configuration from ConfigLoader
        do {
            self.config = try Config.loadConfig()

            // Fetch and set the authentication token asynchronously
            self.createMessagingToken()
            
        } catch {
            // Handle configuration loading failure
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    // MARK: - Save messaging token
    func setMessagingToken(_ token: String) {
        print("Updating messaging token")
        self.token = token
    }
    
    public func getMessagingToken() -> String? {
        return self.token ?? nil
    }
    
    // This method is used to asynchronously fetch the messaging token
    private func createMessagingToken() {
        // Call Networking to fetch the messaging token
        Networking.createMessagingToken { result in
            switch result {
            case .success(let result):
                // Token retrieval successful, extract and print the token
                print("TOKEN", result.token)
                // Set the retrieved token for later use
                self.setMessagingToken(result.token)
                
                // Initialize PubNub with the obtained token
                self.initializePubNub()
                
                // Schedule token refresh every 58 minutes
                self.scheduleRefreshToken()
                
            case .failure(let error):
                // Handle token retrieval failure
                print("Token retrieval failure. Error: \(error.localizedDescription)")
                // You might want to handle the error appropriately, e.g., show an alert to the user or log it.
                break
            }
        }
    }

    // This method initializes PubNub with the obtained token and other settings
    private func initializePubNub() {
        // Configure PubNub with the obtained token and other settings
       
        let configuration = PubNubConfiguration(
            publishKey: self.config.PUBLISH_KEY,
            subscribeKey: self.config.SUBSCRIBE_KEY,
            userId: self.config.USER_ID,
            authKey: self.getMessagingToken()
            // Add more configuration parameters as needed
        )
        // Initialize PubNub instance
        self.pubnub = PubNub(configuration: configuration)
        // Log the initialization
        print("Initialized Pubnub", pubnub!)

    }
    
    // Helper method to schedule token refresh every 58 minutes
    private func scheduleRefreshToken() {
//         Create a timer that fires every 58 minutes
        let refreshTimer = Timer(timeInterval: 58*60, repeats: true) {_ in
            // Call the method to refresh the messaging token
            print("Timer fired - Refreshing token")
            self.refreshToken()
        }
        
        // Add the timer to the main run loop
        RunLoop.main.add(refreshTimer, forMode: .common)
        
        // Optionally, you can store the timer in a property to invalidate it later if needed
         self.refreshTimer = refreshTimer
    }
    
    // Manually invalidate the timer when needed
    private func stopRefreshTokenTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    // Method to refresh the messaging token
    @objc func refreshToken() {
        print("Calling Refresh TOKEN")
        // Call Networking to refresh the messaging token
        Networking.refreshToken { result in
            switch result {
            case .success(let result):
                // Token refresh successful, extract and print the refreshed token
                print("Refreshed TOKEN", result.token)
                // Set the refreshed token for later use
                self.setMessagingToken(result.token)
            case .failure(let error):
                // Handle token refresh failure
                print("Token refresh failure. Error: \(error.localizedDescription)")
                // You might want to handle the error appropriately, e.g., show an alert to the user or log it.
                break
            }
        }
    }
    
}
