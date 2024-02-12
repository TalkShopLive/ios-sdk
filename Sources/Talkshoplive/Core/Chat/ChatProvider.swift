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
    
    public init() {
        // Load configuration from ConfigLoader
        do {
            self.config = try Config.loadConfig()

            // Fetch and set the authentication token asynchronously
            self.createMessagingToken { token in
                // Once the token is obtained, initialize PubNub
                self.initializePubNub(with: token)
            }

        } catch {
            // Handle configuration loading failure
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    // This method is used to asynchronously fetch the messaging token
    internal func createMessagingToken(completion: @escaping (String) -> Void) {
        // Call Networking to fetch the messaging token
        Networking.postMessagingToken { result in
            switch result {
            case .success(let token):
                // Token retrieval successful, pass it to the completion handler
                print("TOKEN", token)
                completion(token)
            case .failure(let error):
                // Handle token retrieval failure
                print(error.localizedDescription)
                break
            }
        }
    }

    // This method initializes PubNub with the obtained token and other settings
    internal func initializePubNub(with token: String?) {
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
