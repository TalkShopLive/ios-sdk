//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

public class ChatProvider {
    
    private var pubnub: PubNub!
    private var config: EnvConfig
    private var token: String?
    private var messageToken : MessagingTokenResponse?
    private var isGuest : Bool
    private var showKey : String?
    private var eventId : String?
    
    public init(jwtToken:String,isGuest:Bool,showKey:String) {
        // Load configuration from ConfigLoader
        do {
            self.isGuest = isGuest
            self.config = try Config.loadConfig()
            self.showKey = showKey
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
//       self.unSubscribeChannels()
       // Perform cleanup or deallocate resources here
//       print("Chat instance is being deallocated.")
   }
    
    // MARK: - Save messaging token
    func setMessagingToken(_ token: MessagingTokenResponse) {
        self.messageToken = token
    }
    
    public func getMessagingToken() -> MessagingTokenResponse? {
        return self.messageToken
    }
    
    // MARK: - Get Show key
    public func getShowKey() -> String? {
        return self.showKey
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
                if let showKey = self.showKey {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.addListeners()
                        self.checkPubnubConnection()
                        self.subscribeChannels(showKey: showKey)
                    }
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
            authToken: messageToken.token
            // Add more configuration parameters as needed
        )
        // Initialize PubNub instance
        self.pubnub = PubNub(configuration: configuration)
        // Log the initialization
        print("Pubnub : Initializing")
    }
    
    
    private func subscribeChannels(showKey:String) {
        Networking.getCurrentEvent(showId: showKey, completion: { result in
            switch result {
            case .success(let apiResponse):
                // Set the details and invoke the completion with success.
                if let eventId = apiResponse.id {
                    self.eventId = "\(eventId)"
                    let publicChannel = "chat.\(eventId)"
                    let eventsChannel = "events.\(eventId)"
                    
                    self.pubnub?.subscribe(to: [publicChannel,eventsChannel])
                    print("Pubnub : Subscribe Channel : \(publicChannel) , \(eventsChannel)")
                    
                    self.fetchMessageHistory()

                }
                
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                print("\(error.localizedDescription)")
            }
        })
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
    
    private func unSubscribeChannels() {
           self.pubnub?.unsubscribeAll()
    }
    
    func checkPubnubConnection() {
        pubnub.onConnectionStateChange = { [weak self] newStatus in
            
            guard let self = self else {
                return
            }
            if newStatus == .connected {
                print("Pubnub Connected")
//                if let showKey = self.showKey {
//                    self.addListeners()
//                    self.subscribeChannels(showKey: showKey)
                    self.fetchMessageHistory()
//                }
            } else {
                print("No Status yet")
            }
        }
    }
    
    func fetchMessageHistory() {
        pubnub.fetchMessageHistory(for: ["chat.\(self.eventId!)"]) { result in
            switch result {
            case let .success(response):
              print("Successfully Message Action Fetch Response: \(response)")

            case let .failure(error):
              print("Error from failed response: \(error.localizedDescription)")
            }
        }
    }
}
