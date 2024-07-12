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
    func onMessageReceived(_ message: MessageBase)
    func onMessageRemoved(_ message: MessageBase)
    func onStatusChange(error:APIClientError)
    func onLikeComment(_ messageAction: MessageAction)
    func onUnlikeComment(_ messageAction: MessageAction)
    // Add more methods for other events if needed
}

// MARK: - ChatProvider Class

// ChatProvider class responsible for managing chat-related functionality
public class ChatProvider {
    
    // MARK: - Properties
    public var delegate: _ChatProviderDelegate?
    public var isUpdateUser: Bool = false
    private var pubnub: PubNub?
    private var messageToken: MessagingTokenResponse?
    private var isGuest: Bool
    private var showKey: String
    private var channels: [String] = []
    private var eventId: Int?
    private var publishChannel: String?
    private var eventsChannel: String?
    private var jwtToken: String?
    private var eventInstance: EventData?
    private var usersProvider = UsersProvider.shared
    private var triedToReconnectBefore = false

    // MARK: - Initializer
    
    /// Initialize ChatProvider with a JWT token and show key
    /// - Parameters:
    ///   - jwtToken: The JWT token used for authentication.
    ///   - isGuest: A boolean indicating whether the user is a guest.
    ///   - showKey: The show key used to configure the chat provider.
    public init(
        jwtToken: String,
        isGuest: Bool,
        showKey: String,
        _ completion: ((Bool, APIClientError?) -> Void)? = nil)
    {
        // Load configuration from ConfigLoader
        self.isGuest = isGuest
        self.showKey = showKey
        self.setJwtToken(jwtToken)
        self.createMessagingToken(jwtToken: jwtToken){result,error  in
            completion?(result,error)
        }
    }
    
    // MARK: - Deinitializer
    
    // Deinitialize the ChatProvider instance
    deinit {
        // Perform cleanup or deallocate resources here
        Config.shared.isDebugMode() ? print("ChatProvider instance is being deallocated.") : ()
    }

    // MARK: - JWT Token
    
    /// Method to save the JWT token.
    /// - Parameter token: The JWT token to be saved.
    func setJwtToken(_ token: String) {
        self.jwtToken = token
    }
    
    /// Get the saved JWT token.
    /// - Returns: The saved JWT token, if available.
    public func getJwtToken() -> String? {
        return self.jwtToken
    }
    
    // MARK: - Messaging Token
    
    ///Save the messaging token
    /// - Parameter token: The messaging token to be saved.
    func setMessagingToken(_ token: MessagingTokenResponse) {
        self.messageToken = token
    }
    
    /// Get the saved messaging token
    /// - Returns: The saved messaging token, if available.
    public func getMessagingToken() -> MessagingTokenResponse? {
        return self.messageToken
    }
    
    // MARK: - Current Event
    
    /// Save the current event
    /// - Parameter token: The current event  to be saved.
    func setCurrentEvent(_ event: EventData) {
        self.eventInstance = event
    }
    
    /// Get the saved messaging token
    /// - Returns: The saved messaging token, if available.
    public func getCurrentEvent() -> EventData? {
        return self.eventInstance
    }

    // MARK: - Create Messaging Token
    
    /// Create a messaging token asynchronously
    /// - Parameter jwtToken: The JWT token used for authentication.
    private func createMessagingToken(
        jwtToken: String,
        _ completion: ((Bool, APIClientError?) -> Void)? = nil)
    {
        // Call Networking to fetch the messaging token
        Networking.createMessagingToken(jwtToken: jwtToken, isGuest: self.isGuest) { result in
            switch result {
            case .success(let result):
                // Token retrieval successful, extract and print the token
                // Set the retrieved token for later use
                self.setMessagingToken(result)
                
                // Initialize PubNub following with the steps :
                // Get eventId based on showKey
                // Initialize pubnub with needed data.
                self.initializePubNub{result,error in
                    completion?(result,error)
                }
            case .failure(let error):
                // Handle token retrieval failure
                Config.shared.isDebugMode() ? print(String(describing: self),"::","Token retrieval Failed: \(error.localizedDescription)") : ()
                // You might want to handle the error appropriately, e.g., show an alert to the user or log it.
                completion?(false,error)
                break
            }
        }
    }
    
    // MARK: - Channel Subscription

    /// Subscribe to channels based on the showKey.
    /// - Parameter showKey: The show key used to determine which channels to subscribe to.
    private func initializePubNub(
        _ completion: ((Bool, APIClientError?) -> Void)? = nil)
    {
        Networking.getCurrentEvent(showKey: self.showKey, completion: { result in
            switch result {
            case .success(let eventData):
                self.setCurrentEvent(eventData)
                // Set the details and invoke the completion with success.
                if let event = self.eventInstance, let eventId = event.id {
                    self.eventId = eventId
                    self.publishChannel = "chat.\(eventId)"
                    self.eventsChannel = "events.\(eventId)"
                    self.channels = [self.publishChannel!, self.eventsChannel!]
                    
                    if let messageToken = self.messageToken {
                        let configuration = PubNubConfiguration(
                            publishKey: messageToken.publishKey,
                            subscribeKey: messageToken.subscribeKey,
                            userId: messageToken.userId,
                            authKey: messageToken.token
                            // Add more configuration parameters as needed
                        )
                        // Initialize PubNub instance
                        self.pubnub = PubNub(configuration: configuration)
                        // Log the initialization
                        Config.shared.isDebugMode() ? print("Initialized Pubnub", self.pubnub!) : ()
                        
                        // Initialize PubNub with the obtained token
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                            self.subscribe()
                            completion?(true,nil)
                            //Analytics
                            Collector.shared.collect(userId: self.messageToken?.userId,
                                                     category: self.isUpdateUser ? .process : .interaction,
                                                     action: self.isUpdateUser ? .updateUser : .selectViewChat,
                                                     eventId: eventId,
                                                     showKey: self.showKey,
                                                     storeId: event.storeId ?? nil,
                                                     videoStatus: event.status ?? nil,
                                                     videoTime: event.duration ?? nil)
                            if self.isUpdateUser {
                                self.isUpdateUser = false
                            }
                        })
                    } else {
                        Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.USER_TOKEN_EXCEPTION) : ()
                        completion?(false,APIClientError.USER_TOKEN_EXCEPTION)
                    }
                } else {
                    Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.SHOW_NOT_LIVE) : ()
                    completion?(false,APIClientError.SHOW_NOT_LIVE)
                }
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.SHOW_NOT_FOUND) : ()
                completion?(false,APIClientError.SHOW_NOT_FOUND)
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
                Config.shared.isDebugMode() ? print("messageReceived:=> The \(message.channel) channel received a listener event at \(message.published)") : ()
                
                // Convert the received message into a MessageBase object
                var convertedMessage = MessageBase(pubNubMessage: message)
                
                // Check the channel type
                switch message.channel {
                case self.publishChannel :
                    // Check if the sender ID exists in the converted message payload.
                        if let senderId = convertedMessage.payload?.sender?.id {
                            // Fetch user metadata using the sender ID.
                            self.usersProvider.fetchUserMetaData(uuid: senderId) { result in
                                switch result {
                                case .success(let senderData):
                                    // Update the sender information in the converted message payload.
                                    convertedMessage.payload?.sender = senderData
                                    
                                    // Notify the delegate on the main thread about the received message.
                                    DispatchQueue.main.async {
                                        self.delegate?.onMessageReceived(convertedMessage)
                                    }
                                    
                                case .failure(let error):
                                    // Print the error if debug mode is enabled.
                                    Config.shared.isDebugMode() ? print(String(describing: self),"::","Error fetching user metadata: \(error.localizedDescription)") : ()
                                    
                                    // Notify the delegate on the main thread about the received message even if there's an error.
                                    DispatchQueue.main.async {
                                        self.delegate?.onMessageReceived(convertedMessage)
                                    }
                                }
                            }
                        }
                    
                case self.eventsChannel:
                    // If the message is from the events channel
                    if let payloadKey = convertedMessage.payload?.key, payloadKey.isEqual(to: .messageDeleted){
                        // If the payload key is "messageDeleted", notify the delegate asynchronously
                        DispatchQueue.main.async {
                            self.delegate?.onMessageRemoved(convertedMessage)
                        }
                    }
                    // Handle other scenarios related to the events channel if needed

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
            case .connectionStatusChanged(let connection):
                Config.shared.isDebugMode() ? print("The connectionStatusChanged") : ()
                if connection == .connected {
                    self.triedToReconnectBefore = false
                } else if connection == .disconnected {
                    if self.triedToReconnectBefore {
                        Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.CHAT_CONNECTION_ERROR) : ()
                        self.delegate?.onStatusChange(error: APIClientError.CHAT_CONNECTION_ERROR)
                    } else {
                        self.triedToReconnectBefore = true
                        self.pubnub?.reconnect()
                    }
                } else {
                    if self.triedToReconnectBefore {
                        Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.CHAT_CONNECTION_ERROR) : ()
                        self.delegate?.onStatusChange(error: APIClientError.CHAT_CONNECTION_ERROR)
                    }
                }
                
            case .subscriptionChanged(_):
                Config.shared.isDebugMode() ? print("The subscriptionChanged") : ()
                
            case .presenceChanged(_):
                Config.shared.isDebugMode() ? print("The presenceChanged") : ()
                
            case .uuidMetadataSet(_):
                Config.shared.isDebugMode() ? print("The uuidMetadataSet") : ()
                
            case .uuidMetadataRemoved(_):
                Config.shared.isDebugMode() ? print("The uuidMetadataRemoved") : ()
                
            case .channelMetadataSet(_):
                Config.shared.isDebugMode() ? print("The channelMetadataSet") : ()
                
            case .channelMetadataRemoved(_):
                Config.shared.isDebugMode() ? print("The channelMetadataRemoved") : ()
                
            case .membershipMetadataSet(_):
                Config.shared.isDebugMode() ? print("The membershipMetadataSet") : ()
                
            case .membershipMetadataRemoved(_):
                Config.shared.isDebugMode() ? print("The membershipMetadataRemoved") : ()
                
            case .messageActionAdded(let messageAction):
                Config.shared.isDebugMode() ? print("The messageActionAdded") : ()
                // Convert the received messageAction into a MessageAction object
                let convertedMessageAction = MessageAction(action: messageAction)
                DispatchQueue.main.async {
                    // Notify the delegate about the new like/comment action
                    self.delegate?.onLikeComment(convertedMessageAction)
                }
                
            case .messageActionRemoved(let messageAction):
                Config.shared.isDebugMode() ? print("The messageActionRemoved", messageAction) : ()
                // Convert the received messageAction into a MessageAction object
                let convertedMessageAction = MessageAction(action: messageAction)
                DispatchQueue.main.async {
                    // Notify the delegate about the unlike/comment removal action
                    self.delegate?.onUnlikeComment(convertedMessageAction)
                }
                
            case .fileUploaded(_):
                Config.shared.isDebugMode() ? print("The fileUploaded") : ()
                
            case .subscribeError(let error):
                Config.shared.isDebugMode() ? print("The subscribeError", error.localizedDescription , "Code", error.reason.rawValue) :()
                if error.reason == .timedOut {
                    self.delegate?.onStatusChange(error: APIClientError.CHAT_TIMEOUT)
                } else  if error.reason.rawValue == 403 {
                    if error.localizedDescription.contains("expired") {
                        Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.CHAT_TOKEN_EXPIRED) : ()
                        self.delegate?.onStatusChange(error: APIClientError.CHAT_TOKEN_EXPIRED)
                    } else {
                        Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.PERMISSION_DENIED) : ()
                        self.delegate?.onStatusChange(error: APIClientError.PERMISSION_DENIED)
                    }
                }  else {
                    if self.triedToReconnectBefore {
                        Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.CHAT_CONNECTION_ERROR) : ()
                        self.delegate?.onStatusChange(error: APIClientError.CHAT_CONNECTION_ERROR)
                    }
                }
            }
        }
        
        // Add the listener to PubNub
        pubnub?.add(listener)
        
        // Subscribe to the configured channels
        pubnub?.subscribe(to: self.channels)
    }


    // MARK: - Publish Message
    
    /// Publishes a message to the configured channel.
    /// - Parameters:
    ///   - message: The message to be published.
    ///   - type: Default will be "comment", Other types are giphy and question.
    ///   - aspectRatio: when type is "giphy", aspectRatio param should pass.
    ///   - completion: A closure to be called after the publishing operation completes. It receives two parameters:
    ///                 - success: A boolean value indicating whether the publishing operation was successful.
    ///                 - error: An optional Error object indicating any error that occurred during the publishing operation.
    internal func publish(
        message: String,
        type: MessageType? = .comment,
        aspectRatio: Double? = nil,
        completion: @escaping (Bool, APIClientError?) -> Void)
    {
        // Check if the message length is within the specified limit
        guard message.count <= 200 else {
            // Handle the case where the message exceeds the maximum length
            print("Message Sending Failed: Message exceeds maximum length of 200 characters.")
            return
        }
        
        if let messageToken = messageToken {
            // Create a MessageData object with relevant information
            var messageObject = MessageData(
                id: Int(Date().milliseconds), //in milliseconds
                createdAt: Date().toString(), //Current Date Object
                sender: Sender(id: messageToken.userId, name: messageToken.userId), // User id obtained from the backend after creating a messaging token)
                platform: "mobile"
                )
            //Check for If MessageType is giphy
            if type == .giphy {
                //If it's giphy, aspectRatio will be setup for publish message.
                if let aspectRatio = aspectRatio {
                    //Setup necessary details to publish giphy
                    messageObject.type = .giphy
                    messageObject.text = message
                    messageObject.aspectRatio = aspectRatio
                } else {
                    completion(false, APIClientError.MESSAGE_SENDING_GIPHY_DATA_NOT_FOUND) // Indicate failure with status false and pass the error
                }
            } else {
                messageObject.type = (message.contains("?") ? .question : .comment)
                messageObject.text = message
            }
            
            // Check if the publish channel is configured
            if let channel = self.publishChannel {
                // Use PubNub's publish method to send the message
                pubnub?.publish(channel: channel, message: messageObject) { result in
                    switch result {
                    case .success(_):
                        Config.shared.isDebugMode() ? print("Message Sent!") : ()
                        completion(true, nil) // Indicate success with status true and no error
                    case let .failure(error):
                        // Print an error message in case of a failure during publishing
                        Config.shared.isDebugMode() ? print("Message Sending Failed: \(String(describing: self)) \(error.localizedDescription)") : ()
                        if (error as? PubNubError)?.reason.rawValue == 403 {
                            if error.localizedDescription.contains("expired") {
                                Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.CHAT_TOKEN_EXPIRED) : ()
                                self.delegate?.onStatusChange(error: APIClientError.CHAT_TOKEN_EXPIRED)
                            } else {
                                Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.PERMISSION_DENIED) : ()
                                self.delegate?.onStatusChange(error: APIClientError.PERMISSION_DENIED)
                            }
                        } else {
                            Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.MESSAGE_SENDING_FAILED) : ()
                            completion(false, APIClientError.MESSAGE_SENDING_FAILED) // Indicate failure with status false and pass the error
                        }
                    }
                }
            } else {
                Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.SHOW_NOT_LIVE) : ()
                completion(false,APIClientError.SHOW_NOT_LIVE)
            }
        } else {
            Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.USER_TOKEN_EXCEPTION) : ()
            completion(false,APIClientError.USER_TOKEN_EXCEPTION)
        }
    }
    
    // MARK: - Fetch Message History
    
    /// Fetches past chat messages using PubNub's message history API.
    /// - Parameters:
    ///   - limit: max number of messages to pull
    ///   - start: timestamp of last fetched message or now
    ///   - completion: A closure to be called upon completion, providing a Result with an array of MessageBase objects,
    ///                 an optional MessagePage for pagination, or an error if the operation fails.
    internal func fetchPastMessages(
        limit: Int = 25,
        start: Int? = nil,
        includeActions: Bool = true,
        includeMeta: Bool = true,
        includeUUID: Bool = true,
        completion: @escaping (Result<([MessageBase], MessagePage?), APIClientError>) -> Void)
    {
        // Use PubNub's fetchMessageHistory method to retrieve message history for specified channels
        let startTimeToken = start != nil ? UInt64(start!) : UInt64(Date().nanoseconds)
        pubnub?.fetchMessageHistory(for: self.channels, includeActions: includeActions, includeMeta: includeMeta, includeUUID: includeUUID, page: PubNubBoundedPageBase(start: startTimeToken, limit: limit), completion: { result in
            do {
                switch result {
                case let .success(response):
                    // Check if there is a next page for pagination and print it in debug mode
                    if let nextPage = response.next {
                        Config.shared.isDebugMode() ? print("History : Next page used for pagination: \(nextPage)") : ()
                    }
                    
                    var messageArray: [MessageBase] = []

                    // Check if the messages for the specified channel exist in the response
                    if let myChannelMessages = response.messagesByChannel[self.publishChannel!] {
                        
                        // Dispatch group to handle asynchronous tasks completion
                        let dispatchGroup = DispatchGroup()
                        
                        for message in myChannelMessages {
                            // Enter the dispatch group for each message
                            dispatchGroup.enter()
                            
                            // Convert the PubNub message to a MessageBase object
                            var convertedMessage = MessageBase(pubNubMessage: message)
                            
                            // Check if the converted message has text content
                            guard convertedMessage.payload?.text != nil else {
                                // Skip converted messages without text
                                dispatchGroup.leave()
                                continue
                            }
                            
                            // Fetch user metadata for the sender of the message
                            if let senderId = convertedMessage.payload?.sender?.id {
                                // Append the message to the message array
                                messageArray.append(convertedMessage)

                                self.usersProvider.fetchUserMetaData(uuid: senderId) { result in
                                    switch result {
                                    case .success(let senderData):
                                        // Update the sender information in the converted message payload
                                        convertedMessage.payload?.sender = senderData
                                        
                                        // Fetch the index of specific message
                                        if let index = messageArray.firstIndex(where: { objMessage in
                                            objMessage.published == convertedMessage.published
                                        }) {
                                            // If index is found, replace it with the updated message
                                            messageArray[index] = convertedMessage
                                        }
                                        // Leave the dispatch group as message processing is complete
                                        dispatchGroup.leave()
                                    case .failure(_):
                                        // Leave the dispatch group as message processing is complete
                                        dispatchGroup.leave()
                                    }
                                }
                            } else {
                                // If sender ID is not available, leave the dispatch group
                                dispatchGroup.leave()
                            }
                        }
                        
                        // Notify when all message processing is complete
                        dispatchGroup.notify(queue: .main) {
                           Config.shared.isDebugMode() ? print("History : Fetched successfully!") : ()
                            // Create a MessagePage object based on the next page information
                            let page = MessagePage(page: response.next as! PubNubBoundedPageBase)
                            // Invoke the completion closure with success and the obtained messages and page
                            completion(.success((messageArray, page)))
                        }
                    } else {
                        // Invoke the completion closure with success and the obtained messages and page
                        completion(.success((messageArray,  response.next != nil ? MessagePage(page: response.next as! PubNubBoundedPageBase) : nil)))
                    }
                    
                case let .failure(error):
                    // Print an error message in case of a failure and invoke the completion closure with the error
                    Config.shared.isDebugMode() ? print("History : Fetch History Failed: \(error.localizedDescription)") : ()
                    if (error as? PubNubError)?.reason.rawValue == 403 {
                        if error.localizedDescription.contains("expired") {
                            Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.CHAT_TOKEN_EXPIRED) : ()
                            self.delegate?.onStatusChange(error: APIClientError.CHAT_TOKEN_EXPIRED)
                        } else {
                            Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.PERMISSION_DENIED) : ()
                            self.delegate?.onStatusChange(error: APIClientError.PERMISSION_DENIED)
                        }
                    } else {
                        Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.MESSAGE_LIST_FAILED) : ()
                        completion(.failure(APIClientError.MESSAGE_LIST_FAILED))
                    }
                }
            }
        })
    }

    
    // MARK: - Clears the connection
    
    /// Clears the connection by unsubscribing from all channels, resetting instance variables to nil, and removing channels from the list.
    internal func clearConnection() {
        // Unsubscribe from all channels
        self.unSubscribeChannels()
        
        // Reset instance variables to nil
        self.pubnub = nil
        self.messageToken = nil
        
        // Remove all channels from the list
        self.channels.removeAll()
        
        // Reset specific channels to nil
        self.publishChannel = nil
        self.eventsChannel = nil
    }
    
    // MARK: - Messages count for specific channel
    internal func count(
        completion: @escaping (Int, APIClientError?) -> Void?)
    {
          // Check if a channel is provided for counting messages
          if let channel = self.publishChannel {
              // Use PubNub to retrieve message counts for the specified channel
              self.pubnub?.messageCounts(channels: [channel], completion: { result in
                  switch result {
                  case let .success(response):
                      // If the count is available for the channel, handle it
                      if let count = response[channel] {
                          // Call the completion handler with the count
                          completion(count, nil)
                      } else {
                          // No count found for the channel, handle this case
                          completion(0, nil)
                      }
                  case let .failure(error):
                      // Handle the failure case when retrieving message counts
                      Config.shared.isDebugMode() ? print("Message Count Failed: \(error.localizedDescription)") : ()
                      if (error as? PubNubError)?.reason.rawValue == 403 {
                          if error.localizedDescription.contains("expired") {
                              Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.CHAT_TOKEN_EXPIRED) : ()
                              self.delegate?.onStatusChange(error: APIClientError.CHAT_TOKEN_EXPIRED)
                          } else {
                              Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.PERMISSION_DENIED) : ()
                              self.delegate?.onStatusChange(error: APIClientError.PERMISSION_DENIED)
                          }
                      } else {
                          Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.UNKNOWN_EXCEPTION) : ()
                          completion(0,APIClientError.UNKNOWN_EXCEPTION)
                      }
                  }
              })
          } else {
              // Handle the case when no channel is provided
              Config.shared.isDebugMode() ? print("Message Count Failed: \(APIClientError.UNKNOWN_EXCEPTION)") : ()
              completion(0,APIClientError.SHOW_NOT_LIVE)
          }
          
      }
    
    // MARK: - Delete Message

    /// Unpublishes a message of specified timetoken.
    /// - Parameters:
    ///   - timetoken: The timetoken of the message when it's published.
    ///   - completion: A closure that receives the result of the deletion operation as a `Result` enum with a `Bool` indicating success or failure and an `Error` in case of failure.
    internal func unPublishMessage(
        timetoken: String,
        completion: @escaping (Result<Bool, APIClientError>) -> Void)
    {
        // Check if the publish channel and JWT token are available
        if let channel = publishChannel, let jwtToken = self.getJwtToken() {
            // Call the Networking's deletMessage method to delete the message
            Networking.deleteMessage(jwtToken: jwtToken, eventId: channel, timeToken: timetoken) { result in
                // Invoke the completion handler with the result of the deletion operation
                switch result {
                case .success(let status):
                    Config.shared.isDebugMode() ? print(String(describing: self),"::","Message Deleted!") : ()
                    completion(.success(status))
                case .failure(let error):
                    Config.shared.isDebugMode() ? print(String(describing: self),"::","Message Deletion Failed: \(error.localizedDescription)") : ()
                    completion(.failure(error))
                }
            }
        } else {
            Config.shared.isDebugMode() ? print(String(describing: self),"::",APIClientError.SHOW_NOT_LIVE) : ()
            completion(.failure(APIClientError.SHOW_NOT_LIVE))
        }
    }
    
    // Method to like a comment using the chat provider.
    internal func likeComment(timeToken: String,_ completion: @escaping (Bool, APIClientError?) -> Void?) {
        // Check if a channel is provided for like comment
        if let channel = self.publishChannel {
            self.pubnub?.addMessageAction(channel: channel, type: "reaction", value: "like", messageTimetoken:  UInt64(timeToken)!, completion: { result in
                switch result {
                case .success(_):
                    Config.shared.isDebugMode() ? print("Liked comment!") : ()
                    // Call the completion handler with success
                    completion(true, nil)
                case .failure(_):
                    // If there's an error, indicate failure with the appropriate error
                    completion(false,APIClientError.LIKE_COMMENT_FAILED)
                }
            })
        } else {
            // Handle the case when no channel is provided
            Config.shared.isDebugMode() ? print("Liked comment Failed: \(APIClientError.SHOW_NOT_LIVE)") : ()
            // Call the completion handler with failure and the appropriate error
            completion(false,APIClientError.SHOW_NOT_LIVE)
        }
    }
    
    // Method to unlike a comment using the chat provider.
    internal func unlikeComment(timeToken: String,actionTimeToken: Int, _ completion: @escaping (Result<Bool, APIClientError>) -> Void?) {
        // Check if the publish channel and JWT token are available
        if let _ = publishChannel, let jwtToken = self.getJwtToken(), let eventId = self.eventId {
            // Call the Networking's unlikeComment method to unlike a comment
            Networking.unlikeComment(jwtToken: jwtToken, eventId: "\(eventId)", messageTimetoken: timeToken, actionTimeToken: "\(actionTimeToken)") { result in
                // Invoke the completion handler with the result of the unlike comment operation
                switch result {
                case .success(let status):
                    Config.shared.isDebugMode() ? print("Comment unliked!") : ()
                    // Call the completion handler with success status
                    completion(.success(status))
                case .failure(let error):
                    Config.shared.isDebugMode() ? print("Comment Unliked Failed: \(error.localizedDescription)") : ()
                    // Call the completion handler with the failure status and error
                    completion(.failure(error))
                }
            }
        } else {
            // If required parameters are not available, call the completion handler with a failure status
            completion(.failure(APIClientError.SHOW_NOT_LIVE))
        }
    }
}
