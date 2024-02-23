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
    private var messageToken : MessagingTokenResponse?
    private var isGuest : Bool
    
    public init(jwtToken:String,isGuest:Bool) {
        // Load configuration from ConfigLoader
        do {
            self.isGuest = isGuest
            self.config = try Config.loadConfig()
            self.createMessagingToken(jwtToken: jwtToken)
            
        } catch {
            // Handle configuration loading failure
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    // MARK: - Deinitializer
    /*
     When this will get deallocated :
    var chatInstance: ChatProvider? = ChatProvider()
    chatInstance = nil
     */
    deinit {
        self.unSubscribeChannels()
        // Perform cleanup or deallocate resources here
        print("Chat instance is being deallocated.")        
    }
    
    // MARK: - Save messaging token
    func setMessagingToken(_ token: MessagingTokenResponse) {
        self.messageToken = token
    }
    
    public func getMessagingToken() -> MessagingTokenResponse? {
        return self.messageToken
    }
    
    // This method is used to asynchronously fetch the messaging token
    private func createMessagingToken(jwtToken:String) {
        // Call Networking to fetch the messaging token
        Networking.createMessagingToken(jwtToken: jwtToken,isGuest: self.isGuest) { result in
            switch result {
            case .success(let result):
                // Token retrieval successful, extract and print the token
                // Set the retrieved token for later use
                self.setMessagingToken(result)
                
                // Initialize PubNub with the obtained token
                self.initializePubNub()
                
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
       
        if let messageToken = self.messageToken {
            let configuration = PubNubConfiguration(
                publishKey: messageToken.publish_key,
                subscribeKey: messageToken.subscribe_key,
                userId: messageToken.user_id,
                authKey: messageToken.token
                // Add more configuration parameters as needed
            )
            // Initialize PubNub instance
            self.pubnub = PubNub(configuration: configuration)
            // Log the initialization
            print("Initialized Pubnub", pubnub!)
        }
    }
    
    
    private func subscribeChannels(showId: String) {
        Networking.getCurrentEvent(showId: showId, completion: { result in
            switch result {
            case .success(let apiResponse):
                // Set the details and invoke the completion with success.
                if let eventId = apiResponse.id {
                    let publicChannel = "chat.\(eventId)"
                    let eventsChannel = "events.\(eventId)"
                    self.pubnub?.subscribe(to: [publicChannel,eventsChannel])
                }
                
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                print("\(error.localizedDescription)")
            }
        })
    }
    
    private func unSubscribeChannels() {
        self.pubnub?.unsubscribeAll()
    }
    
    
}
