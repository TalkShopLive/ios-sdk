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
        self.token = token
    }
    
    public func getToken() -> String? {
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
                self.initializePubNub(with: self.getToken())
                
            case .failure(let error):
                // Handle token retrieval failure
                print("Token retrieval failure. Error: \(error.localizedDescription)")
                // You might want to handle the error appropriately, e.g., show an alert to the user or log it.
                break
            }
        }
    }

    // This method initializes PubNub with the obtained token and other settings
    private func initializePubNub(with token: String?) {
        // Configure PubNub with the obtained token and other settings
        let configuration = PubNubConfiguration(
            publishKey: self.config.PUBLISH_KEY,
            subscribeKey: self.config.SUBSCRIBE_KEY,
            userId: self.config.USER_ID,
            authKey: token
            // Add more configuration parameters as needed
        )
        // Initialize PubNub instance
        self.pubnub = PubNub(configuration: configuration)
        // Log the initialization
        print("Initialized Pubnub", pubnub!)
    }
    
}
