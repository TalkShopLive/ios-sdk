// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import PubNub

let PUBLISH_KEY = "pub-c-1e61c0eb-d528-4c4c-95b5-f04e6a5f3a6f"
let SUBSCRIBE_KEY = "sub-c-cc752c97-2cd6-4166-a237-b65b01017299"
let UserId = "oyrVT6p94Ep"

public class PubNubHandler {
    static let shared = PubNubHandler()
    private var pubnub: PubNub
    private var authKey: String?
    
    public init() {
        // Initialize PubNub configuration
        let config = PubNubConfiguration(
            publishKey: PUBLISH_KEY,
            subscribeKey: SUBSCRIBE_KEY,
            userId: UserId
            // Add more configuration parameters as needed
        )
        self.pubnub = PubNub(configuration: config)
        // Fetch and set the authentication key asynchronously
        fetchAuthKey { [weak self] authKey in
            self?.authKey = authKey
            
            // Once authKey is obtained, update PubNub configuration
            self?.updatePubNubConfiguration()
        }
    }
    
    public func fetchAuthKey(completion: @escaping (String) -> Void) {
        // Call your APIClient.postMessagingToken here
        // This is just a placeholder, replace it with your actual implementation
        APIClient.postMessagingToken { result in
            switch result {
            case .success(let token):
                print("AUTH KEY", token)
                completion(token)
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    private func updatePubNubConfiguration() {
        guard let authKey = authKey else {
            // Handle the case where authKey is not available
            return
        }
        
        // Create a new PubNubConfiguration with the updated authKey
        let updatedConfig = PubNubConfiguration(
            publishKey: PUBLISH_KEY,
            subscribeKey: SUBSCRIBE_KEY,
            userId: UserId,
            authKey: authKey
            // Add more configuration parameters as needed
        )
        
        // Create a new PubNub instance with the updated configuration
        let updatedPubNub = PubNub(configuration: updatedConfig)
        
        // Replace the existing PubNub instance with the updated one
        pubnub = updatedPubNub
        print("Initialized PUBNUB",pubnub)
    }
}
