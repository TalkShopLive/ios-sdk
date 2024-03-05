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
        Config.shared.isDebugMode() ? print("Chat instance is being deallocated.") : ()
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
                Config.shared.isDebugMode() ? print("Token retrieval failure. Error: \(error.localizedDescription)") : ()
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
            Config.shared.isDebugMode() ? print("Initialized Pubnub", pubnub!) : ()
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
                Config.shared.isDebugMode() ? print("\(error.localizedDescription)") : ()
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
                Config.shared.isDebugMode() ? print("The \(message.channel) channel received a message at \(message.published)") : ()
                
                // Check if there is a subscription info
                if let subscription = message.subscription {
                    Config.shared.isDebugMode() ? print("The channel-group or wildcard that matched this channel was \(subscription)") : ()
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
                    Config.shared.isDebugMode() ? print("The message is \(message.payload) and was sent by \(message.publisher ?? "")") : ()
                    break
                }
                
            case .signalReceived(let signal):
                // Handle signal received event
                Config.shared.isDebugMode() ? print("The \(signal.channel) channel received a message at \(signal.published)") : ()
                
                // Check if there is a subscription info
                if let subscription = signal.subscription {
                    Config.shared.isDebugMode() ? print("The channel-group or wildcard that matched this channel was \(subscription)") : ()
                }
                
                // Log the signal information
                Config.shared.isDebugMode() ? print("The signal is \(signal.payload) and was sent by \(signal.publisher ?? "")") : ()
                
            // Handle other events
            case .connectionStatusChanged(_):
                Config.shared.isDebugMode() ? print("The connectionStatusChanged") : ()
                
            case .subscriptionChanged(_):
                Config.shared.isDebugMode() ? print("The subscriptionChanged") : ()
                
            case .presenceChanged(_):
                Config.shared.isDebugMode() ? print("The presenceChanged") : ()
                
            case .uuidMetadataSet(_):
                Config.shared.isDebugMode() ? print("The uuidMetadataSet") : ()
                
            case .uuidMetadataRemoved(metadataId: let metadataId):
                Config.shared.isDebugMode() ? print("The uuidMetadataRemoved") : ()
                
            case .channelMetadataSet(_):
                Config.shared.isDebugMode() ? print("The channelMetadataSet") : ()
                
            case .channelMetadataRemoved(metadataId: let metadataId):
                Config.shared.isDebugMode() ? print("The channelMetadataRemoved") : ()
                
            case .membershipMetadataSet(_):
                Config.shared.isDebugMode() ? print("The membershipMetadataSet") : ()
                
            case .membershipMetadataRemoved(_):
                Config.shared.isDebugMode() ? print("The membershipMetadataRemoved") : ()
                
            case .messageActionAdded(_):
                Config.shared.isDebugMode() ? print("The messageActionAdded") : ()
                
            case .messageActionRemoved(_):
                Config.shared.isDebugMode() ? print("The messageActionRemoved") : ()
                
            case .fileUploaded(_):
                Config.shared.isDebugMode() ? print("The fileUploaded") : ()
                
            case .subscribeError(_):
                Config.shared.isDebugMode() ? print("The subscribeError") :()
            }
        }
        
        // Add the listener to PubNub
        pubnub?.add(listener)
        
        // Subscribe to the configured channels
        pubnub?.subscribe(to: self.channels)
    }


    // MARK: - Message Publishing
    
    /// Publishes a message to the configured channel.
    /// - Parameter message: The message to be published.
    internal func publish(message: String) {
        // Check if the message length is within the specified limit
        guard message.count <= 200 else {
            // Handle the case where the message exceeds the maximum length
            print("Publishing Error:: Message exceeds maximum length of 200 characters.")
            return
        }
        
        // Create a MessageData object with relevant information
        let messageObject = MessageData(
            id: Int(Date().milliseconds), //in milliseconds
            createdAt: Date().toString(), //Current Date Object
            sender: messageToken?.user_id, // User id obtained from the backend after creating a messaging token
            text: message,
            type: (message.contains("?") ? .question : .comment),
            platform: "sdk")
        
        // Check if the publish channel is configured
        if let channel = self.publishChannel {
            // Use PubNub's publish method to send the message
            pubnub?.publish(channel: channel, message: messageObject) { result in
                switch result {
                case let .success(timetoken):
                    Config.shared.isDebugMode() ? print("Publish Response at \(timetoken)") : ()
                case let .failure(error):
                    // Print an error message in case of a failure during publishing
                    print("Publishing Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Fetch Message History
    
    /// Fetches past chat messages using PubNub's message history API.
    /// - Parameters:
    ///   - page: An optional pagination parameter representing the page to retrieve.
    ///   - completion: A closure to be called upon completion, providing a Result with an array of MessageBase objects,
    ///                 an optional MessagePage for pagination, or an error if the operation fails.
     internal func fetchPastMessages(page: MessagePage? = nil,completion: @escaping (Result<([MessageBase], MessagePage?), Error>) -> Void) {
         // Use PubNub's fetchMessageHistory method to retrieve message history for specified channels
         pubnub?.fetchMessageHistory(for: self.channels, includeActions: true, includeMeta: true, page: page?.toPubNubBoundedPageBase(), completion: { result in
             do {
                 switch result {
                 case let .success(response):
                     // Check if there is a next page for pagination and print it in debug mode
                     if let nextPage = response.next {
                         Config.shared.isDebugMode() ? print("The next page used for pagination: \(nextPage)") : ()
                     }
                     
                     // Check if the messages for the specified channel exist in the response
                     if let myChannelMessages = response.messagesByChannel[self.publishChannel!] {
                         // Convert the dictionary into an array of MessageBase
                         let messageArray : [MessageBase] = myChannelMessages.compactMap { message in
                             return MessageBase(pubNubMessage: message)
                         }
                         
                         // Create a MessagePage object based on the next page information
                         let page = MessagePage(page: response.next as! PubNubBoundedPageBase)
                         
                         Config.shared.isDebugMode() ? print("Message Array", messageArray) : ()
                         
                         // Invoke the completion closure with success and the obtained messages and page
                         completion(.success((messageArray,page)))
                         
                     }
                     
                 case let .failure(error):
                     // Print an error message in case of a failure and invoke the completion closure with the error
                     print("Failed History Fetch Response: \(error.localizedDescription)")
                     completion(.failure(error))
                 }
             } catch {
                 // Print an error message if there is an issue processing the response and invoke the completion closure with the error
                 print("Error processing PubNub message history response: \(error)")
                 completion(.failure(error))
             }
         })
     }

}
