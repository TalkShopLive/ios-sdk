//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

public class Chat: ChatProviderData {

    // MARK: - Properties

    private var pubnub: PubNub?
    private let eventId: String
    private let mode: String
    private let refresh: String
    private var config: Config

    // MARK: - Initializer

    public init(eventId: String, mode: String, refresh: String) {
        // Initialize properties
        self.eventId = eventId
        self.mode = mode
        self.refresh = refresh

        // Load configuration from ConfigLoader
        do {
            self.config = try ConfigLoader.loadConfig()

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

    // MARK: - Public Methods

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

