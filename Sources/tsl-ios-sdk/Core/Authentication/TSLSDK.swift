// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import PubNub

public class TSLSDK {
    public static let shared = TSLSDK()
    public var pubnub: PubNub
    public var authKey: String?
    /*public*/ var config : Config
    
    public init() {
        do {
            self.config = try ConfigLoader.loadConfig()
            print("PUBLISH Key: \(config.PUBLISH_KEY)")
            print("Subscribe_key Key: \(config.SUBSCRIBE_KEY)")
            
            // Initialize PubNub configuration
            let configuration = PubNubConfiguration(
                publishKey: config.PUBLISH_KEY,
                subscribeKey: config.SUBSCRIBE_KEY,
                userId:config.USER_ID
                // Add more configuration parameters as needed
            )
            self.pubnub = PubNub(configuration: configuration)
            // Fetch and set the authentication key asynchronously
            fetchAuthKey { [weak self] authKey in
                self?.authKey = authKey
                
                // Once authKey is obtained, update PubNub configuration
                self?.updatePubNubConfiguration()
            }
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    public func `init`(publishKey:String,subscribeKey:String) {
        do {
            self.config = try ConfigLoader.loadConfig()
            print("PUBLISH Key: \(config.PUBLISH_KEY)")
            print("Subscribe_key Key: \(config.SUBSCRIBE_KEY)")
            
            // Initialize PubNub configuration
            let configuration = PubNubConfiguration(
                publishKey: config.PUBLISH_KEY,
                subscribeKey: config.SUBSCRIBE_KEY,
                userId:config.USER_ID
                // Add more configuration parameters as needed
            )
            self.pubnub = PubNub(configuration: configuration)
            // Fetch and set the authentication key asynchronously
            fetchAuthKey { [weak self] authKey in
                self?.authKey = authKey
                
                // Once authKey is obtained, update PubNub configuration
                self?.updatePubNubConfiguration()
            }
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    public func fetchAuthKey(completion: @escaping (String) -> Void) {
        // Call your APIClient.postMessagingToken here
        // This is just a placeholder, replace it with your actual implementation
        Networking.postMessagingToken { result in
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
            publishKey: self.config.PUBLISH_KEY,
            subscribeKey: self.config.SUBSCRIBE_KEY,
            userId: self.config.USER_ID,
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
