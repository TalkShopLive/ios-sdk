//
//  ChatProvider.swift
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
    private var showKey : String
    private var channels : [String] = []
    private var channelToPublish : String?

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
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: {
                    self.subscribeChannels(showId: self.showKey)
                })
                
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
                    self.channelToPublish = "chat.\(eventId)"
                    let eventsChannel = "events.\(eventId)"
                    self.channels = [self.channelToPublish!,eventsChannel]
                    self.subscribeChannels()
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
    
    private func subscribeChannels() {
        let listener = SubscriptionListener(queue: .main)
        listener.didReceiveSubscription = { event in
            switch event {
            case .messageReceived(let message):
                print("The \(message.channel) channel received a message at \(message.published)")
                if let subscription = message.subscription {
                    print("The channel-group or wildcard that matched this channel was \(subscription)")
                }
                print("The message is \(message.payload) and was sent by \(message.publisher ?? "")")
                DispatchQueue.main.async {
                    print(message.payload)
                }
            case .signalReceived(let signal):
                  print("The \(signal.channel) channel received a message at \(signal.published)")
                  if let subscription = signal.subscription {
                    print("The channel-group or wildcard that matched this channel was \(subscription)")
                  }
                  print("The signal is \(signal.payload) and was sent by \(signal.publisher ?? "")")
            case .connectionStatusChanged(_):
                print("The connectionStatusChanged")
            case .subscriptionChanged(_):
                print("The subscriptionChanged")
            case .presenceChanged(_):
                print("The presenceChanged")
            case .uuidMetadataSet(_):
                print("The uuidMetadataSet")
            case .uuidMetadataRemoved(metadataId: let metadataId):
                print("The uuidMetadataRemoved")
            case .channelMetadataSet(_):
                print("The channelMetadataSet")
            case .channelMetadataRemoved(metadataId: let metadataId):
                print("The channelMetadataRemoved")
            case .membershipMetadataSet(_):
                print("The membershipMetadataSet")
            case .membershipMetadataRemoved(_):
                print("The membershipMetadataRemoved")
            case .messageActionAdded(_):
                print("The messageActionAdded")
            case .messageActionRemoved(_):
                print("The messageActionRemoved")
            case .fileUploaded(_):
                print("The fileUploaded")
            case .subscribeError(_):
                print("The subscribeError")
            }
        }
        pubnub?.add(listener)
        pubnub?.subscribe(to: self.channels)
    }

    func publish(message: String) {
        if let channel = self.channelToPublish {
            pubnub?.publish(channel: channel, message: message) { result in
                switch result {
                case let .success(timetoken):
                    print("Publish Response at \(timetoken)")
                case let .failure(error):
                    print("Publishing Error: \(error.localizedDescription)")
                }
            }
        }
          
    }
}
