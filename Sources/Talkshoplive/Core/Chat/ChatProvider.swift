//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub


public class ChatProvider {
    
    public static let shared = ChatProvider()
    private var pubnub: PubNub!
    private var config: EnvConfig
    private var token: String?
    private var messageToken : MessagingTokenResponse?
    private var showKey : String?
    
    public init(showKey:String? = nil) {
        // Load configuration from ConfigLoader
        do {
            self.config = try Config.loadConfig()
            self.showKey = showKey

            // Fetch and set the authentication token asynchronously
            self.createMessagingToken()
            
            PubNub.log.levels = [.all]
            PubNub.log.writers = [ConsoleLogWriter(), FileLogWriter()]
            
        } catch {
            // Handle configuration loading failure
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    // MARK: - Save messaging token
    func setMessagingToken(_ token: MessagingTokenResponse) {
        self.messageToken = token
    }
    
    public func getMessagingToken() -> MessagingTokenResponse? {
        return self.messageToken
    }
    
    // This method is used to asynchronously fetch the messaging token
    private func createMessagingToken() {
        // Call Networking to fetch the messaging token
        print("Pubnub : Creating Messaging Token")
        Networking.createMessagingToken { result in
            switch result {
            case .success(let result):
                // Token retrieval successful, extract and print the token
                // Set the retrieved token for later use
                self.setMessagingToken(result)
                            
                // Initialize PubNub with the obtained token
                self.initializePubNub()
                
                if let showKey = self.showKey {
                    self.subscribeChannels(showKey: showKey)
                    
                    self.addListeners()
                }
                                
            case .failure(let error):
                // Handle token retrieval failure
                print("Pubnub : Token retrieval failure. Error: \(error.localizedDescription)")
                // You might want to handle the error appropriately, e.g., show an alert to the user or log it.
                break
            }
        }
    }

    // This method initializes PubNub with the obtained token and other settings
    private func initializePubNub() {
        // Configure PubNub with the obtained token and other settings
       
        guard let messageToken = self.messageToken else {
                print("Pubnub: Unable to initialize PubNub. Messaging token is nil.")
                return
            }
        let configuration = PubNubConfiguration(
            publishKey: self.config.PUBLISH_KEY,
            subscribeKey: self.config.SUBSCRIBE_KEY,
            userId: messageToken.user_id,
            authKey: messageToken.token
            // Add more configuration parameters as needed
        )
        // Initialize PubNub instance
        self.pubnub = PubNub(configuration: configuration)
        // Log the initialization
        print("Pubnub : Initializing")
    }
    
    
    private func subscribeChannels(showKey: String) {
        Networking.getCurrentEvent(showId: showKey, completion: { result in
            switch result {
            case .success(let apiResponse):
                // Set the details and invoke the completion with success.
                if let eventId = apiResponse.id {
                    let publicChannel = "chat.\(eventId)"
                    let eventsChannel = "events.\(eventId)"
                    
                    self.pubnub?.subscribe(to: [publicChannel,eventsChannel])
                    print("Pubnub : Subscribe Channel : \(publicChannel) , \(eventsChannel)")
                }
                
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                print("\(error.localizedDescription)")
            }
        })
//        let publicChannel = "chat.14650"
//        let eventsChannel = "events.14650"
//        self.pubnub.subscribe(to: [publicChannel,eventsChannel],withPresence: true)
//        print("Pubnub : Subscribe Channel : \(publicChannel) , \(eventsChannel)")
    }
    
    private func addListeners() {
        let listener = SubscriptionListener(queue: .main)
        listener.didReceiveMessage = { message in
            print("Pubnub Listener didReceiveMessage : Message Received: \(message) Publisher: \(message.publisher ?? "defaultUUID")")
        }
        
        listener.didReceiveSubscription = { event in
            switch event {
            case let .messageReceived(message):
                print("Pubnub Listener : Message Received: \(message) Publisher: \(message.publisher ?? "defaultUUID")")
            case let .connectionStatusChanged(status):
                print("Pubnub Listener : Status Received: \(status)")
            case let .presenceChanged(presence):
                print("Pubnub Listener : Presence Received: \(presence)")
            case let .subscribeError(error):
                print("Pubnub Listener : Subscription Error \(error)")
            default:
                break
            }
        }
        self.pubnub.add(listener)
        print("Pubnub: Listeners added.")
    }
    
    
}
