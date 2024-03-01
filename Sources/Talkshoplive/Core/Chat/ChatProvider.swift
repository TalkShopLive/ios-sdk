//
//  ChatProvider.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

// MARK: - ChatProviderDelegate

// Protocol for the chat provider delegate to handle different chat events
public protocol _ChatProviderDelegate: AnyObject {
    func onMessageReceived(_ message: MessageData)
    // Add more methods for other events if needed
}

// MARK: - ChatProvider Class

// ChatProvider class responsible for managing chat-related functionality
public class ChatProvider {
    
    // MARK: - Properties
    
    private var pubnub: PubNub?
    private var config: EnvConfig
    private var token: String?
    private var messageToken: MessagingTokenResponse?
    private var isGuest: Bool
    private var showKey: String
    private var channels: [String] = []
    private var publishChannel: String?
    private var eventsChannel: String?
    public var delegate: _ChatProviderDelegate?

    // MARK: - Initializer
    
    // Initialize ChatProvider with a JWT token and show key
    public init(jwtToken: String, isGuest: Bool, showKey: String) {
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
    
    // Deinitialize the ChatProvider instance
    deinit {
        self.unSubscribeChannels()
        // Perform cleanup or deallocate resources here
        print("Chat instance is being deallocated.")
    }

    // MARK: - Messaging Token
    
    // Save the messaging token
    func setMessagingToken(_ token: MessagingTokenResponse) {
        self.messageToken = token
    }
    
    // Get the saved messaging token
    public func getMessagingToken() -> MessagingTokenResponse? {
        return self.messageToken
    }

    // Create a messaging token asynchronously
    private func createMessagingToken(jwtToken: String) {
        // Call Networking to fetch the messaging token
        Networking.createMessagingToken(jwtToken: jwtToken, isGuest: self.isGuest) { result in
            switch result {
            case .success(let result):
                // Token retrieval successful, extract and print the token
                // Set the retrieved token for later use
                self.setMessagingToken(result)
                
                // Initialize PubNub with the obtained token
                self.initializePubNub()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                    self.subscribeChannels(showKey: self.showKey)
                })
                
            case .failure(let error):
                // Handle token retrieval failure
                print("Token retrieval failure. Error: \(error.localizedDescription)")
                // You might want to handle the error appropriately, e.g., show an alert to the user or log it.
                break
            }
        }
    }

    // MARK: - PubNub Initialization

    // Initialize PubNub with the obtained token and other settings
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
    
    
    // MARK: - Channel Subscription

    // Subscribe to channels based on the showKey
    private func subscribeChannels(showKey: String) {
        Networking.getCurrentEvent(showKey: showKey, completion: { result in
            switch result {
            case .success(let apiResponse):
                // Set the details and invoke the completion with success.
                if let eventId = apiResponse.id {
                    self.publishChannel = "chat.\(eventId)"
                    self.eventsChannel = "events.\(eventId)"
                    self.channels = [self.publishChannel!, self.eventsChannel!]
                    self.subscribe()
                }
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                print("\(error.localizedDescription)")
            }
        })
    }

    // Unsubscribe from all channels
    private func unSubscribeChannels() {
        self.pubnub?.unsubscribeAll()
    }

    // Subscribe to configured channels and handle events
    private func subscribe() {
        // Create a listener for subscription events
        let listener = SubscriptionListener(queue: .main)
        
        listener.didReceiveSubscription = { event in
            // Handle different subscription events
            switch event {
            case .messageReceived(let message):
                // Handle message received event
                print("The \(message.channel) channel received a message at \(message.published)")
                
                // Check if there is a subscription info
                if let subscription = message.subscription {
                    print("The channel-group or wildcard that matched this channel was \(subscription)")
                }
                
                // Check the channel type
                switch message.channel {
                case self.publishChannel :
                    // If it's the publish channel, notify the delegate
                    if let payloadString = message.payload.jsonStringify {
                        if let messageData = convertToModel(from: payloadString, responseType: MessageData.self) {
                            // Notify the delegate if needed
                            DispatchQueue.main.async {
                                self.delegate?.onMessageReceived(messageData)
                            }
                        }
                    }
                case self.eventsChannel:
                    // Handle events channel if needed
                    break
                default :
                    // Handle other channels
                    print("The message is \(message.payload) and was sent by \(message.publisher ?? "")")
                    break
                }
                
            case .signalReceived(let signal):
                // Handle signal received event
                print("The \(signal.channel) channel received a message at \(signal.published)")
                
                // Check if there is a subscription info
                if let subscription = signal.subscription {
                    print("The channel-group or wildcard that matched this channel was \(subscription)")
                }
                
                // Log the signal information
                print("The signal is \(signal.payload) and was sent by \(signal.publisher ?? "")")
                
            // Handle other events
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
        
        // Add the listener to PubNub
        pubnub?.add(listener)
        
        // Subscribe to the configured channels
        pubnub?.subscribe(to: self.channels)
    }


    // MARK: - Message Publishing
    
    // Publish a message to the configured channel
    func publish(message: String) {        
        let messageObject = MessageData(
            id: Int(Date().millisecondsSince1970), //in milliseconds
            createdAt: Date().toString(), //Current Date Object
            sender: messageToken?.user_id,// User id we get from backend after creating messaging token
            text: message,
            type: .comment,  // either one - question if string contains "?"
            platform: "sdk")
            if let channel = self.publishChannel {
                pubnub?.publish(channel: channel, message: messageObject) { result in
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
