//
//  Chat.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

// MARK: - ChatDelegate

// Protocol for the chat delegate to handle different chat events
public protocol ChatDelegate: AnyObject {
    func onNewMessage(_ message: MessageBase)
    func onDeleteMessage(_ message: MessageBase)
    // Add more methods for other events if needed
}

// MARK: - Chat Class

public class Chat {
    
    // MARK: - Properties
    
    private let showKey: String
    private var chatProvider: ChatProvider?
    public var delegate: ChatDelegate?
    
    // MARK: - Initializer
    
    /// Initializes a Chat instance with the provided parameters.
    ///
    /// - Parameters:
    ///   - jwtToken: The JWT token for authentication.
    ///   - isGuest: A flag indicating whether the user is a guest or fedarated user.
    ///   - showKey: The unique key associated with the show using that to subscribe channel for specific event.
    public init(jwtToken: String, isGuest: Bool, showKey: String,_ completion: ((Bool, APIClientError?) -> Void)? = nil) {

        // Set the showKey property
        self.showKey = showKey
        
        // Initialize ChatProvider for handling chat functionality using JWT Token
        self.chatProvider = ChatProvider(jwtToken: jwtToken, isGuest: isGuest, showKey: showKey) {result,error in
            if  Config.shared.isDebugMode() {
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("Token Created!")
                }
            }
            completion?(result,error)
        }
        
        // Set the delegate to receive chat events from ChatProvider
        self.chatProvider?.delegate = self
    }
    
    // MARK: - Deinitializer
    
    // Deinitialize the ChatProvider instance
    deinit {
        // Perform cleanup or deallocate resources here
        Config.shared.isDebugMode() ? print("Chat instance is being deallocated.") : ()
    }
    
    // MARK: - Public Methods
    
    // Method to send a new message
    /// - Parameters:
    ///   - message: The message to be sent.
    ///   - completion: A closure to be called after the message sending operation completes. It receives two parameters:
    ///                 - success: A boolean value indicating whether the message sending operation was successful.
    ///                 - error: An optional Error object indicating any error that occurred during the message sending operation.
    public func sendMessage(message: String, completion: @escaping (Bool, APIClientError?) -> Void) {
        // Call the publish method in ChatProvider to send the message
        self.chatProvider?.publish(message: message, completion: completion)
    }
    
    // Method to retrieve chat messages, optionally specifying a page for pagination.
    /// - Parameters:
    ///   - limit: The maximum number of messages to retrieve. Default is 25.
    ///   - start: The index to start retrieving messages from. Default is nil.
    ///   - includeActions: A boolean indicating whether to include message actions. Default is true.
    ///   - includeMeta: A boolean indicating whether to include message metadata. Default is true.
    ///   - includeUUID: A boolean indicating whether to include UUID in the message. Default is true.
    ///   - completion: A closure to be called after the message retrieval operation completes. It receives a `Result` enum with an array of `MessageBase` objects and an optional `MessagePage` for pagination.
    public func getChatMessages(limit: Int? = 25, start: Int? = nil, includeActions: Bool = true, includeMeta: Bool = true, includeUUID: Bool = true, completion: @escaping (Result<([MessageBase], MessagePage?), APIClientError>) -> Void) {
        // Call the fetchPastMessages method in ChatProvider to retrieve past messages
        self.chatProvider?.fetchPastMessages(limit: limit ?? 25, start: start, includeActions: includeActions, includeMeta: includeMeta, includeUUID: includeUUID, completion: { result in
            completion(result)
        })
    }

    // Clears all resources
    public func clean() {
        // Remove the delegate to prevent potential retain cycles
        self.chatProvider?.delegate = nil
        
        // Clear the connection and release any resources held by the chat provider
        self.chatProvider?.clearConnection()
        
        // Set the chat provider to nil to release its reference and free up memory
        self.chatProvider = nil
    }

    // Method to update user
    /// - Parameters:
    ///   - jwtToken: The new JWT token to update the user.
    ///   - isGuest: A boolean indicating whether the user is a guest.
    ///   - completion: A closure to be called after the user update operation completes. It receives two parameters:
    ///                 - success: A boolean value indicating whether the user update operation was successful.
    ///                 - error: An optional Error object indicating any error that occurred during the user update operation.
    public func updateUser(jwtToken: String, isGuest: Bool, completion: @escaping (Bool, APIClientError?) -> Void) {
        // Check if there's an existing JWT token
        if let existingToken = self.chatProvider?.getJwtToken() {
            // Compare existing token with the new token
            if existingToken != jwtToken {
                // Create a new ChatProvider instance with updated parameters
                let newChatProvider = ChatProvider(jwtToken: jwtToken, isGuest: isGuest, showKey: self.showKey)
                
                newChatProvider.isUpdateUser = true
                
                // Set the delegate to receive chat events from the new ChatProvider
                newChatProvider.delegate = self
                // Update the chatProvider property with the new instance
                self.chatProvider = newChatProvider
                // Call completion handler indicating success
                completion(true,nil)
                
            } else {
                // If the new token is the same as the existing one, indicate failure with sameToken error
                completion(false,APIClientError.USER_ALREADY_AUTHENTICATED)
            }
        } else {
            // If there's no existing token, indicate failure with somethingWentWrong error
            completion(false,APIClientError.UNKNOWN_EXCEPTION)
        }
    }
    
    // Method to delete a message with a specific time token
    /// - Parameters:
    ///   - timeToken: The timetoken of the message to be deleted.
    ///   - completion: A closure to be called after the message deletion operation completes. It receives two parameters:
    ///                 - success: A boolean value indicating whether the message deletion operation was successful.
    ///                 - error: An optional Error object indicating any error that occurred during the message deletion operation.
    public func deleteMessage(timeToken: String, completion: @escaping (Bool, APIClientError?) -> Void) {
        // Call the ChatProvider's unPublishMessage method to delete the message
        self.chatProvider?.unPublishMessage(timetoken: timeToken) { result in
            switch result {
            case .success(let status):
                // Set the status and invoke the completion handler with success.
                completion(status, nil)
            case .failure(let error):
                // Invoke the completion handler with failure if an error occurs.
                completion(false, error)
            }
        }
    }

    //Methos to count the total number of messages using the chat provider.
    public func countMessages(_ completion: @escaping (Int, APIClientError?) -> Void?) {
        // Call the count method of the chat provider, passing the completion closure
        self.chatProvider?.count(completion: completion)
    }
}

// MARK: - Chat Listeners

// Extend Chat to conform to _ChatProviderDelegate for handling messages received from ChatProvider
extension Chat: _ChatProviderDelegate {
    
    // Delegate method called when a new message is received
    public func onMessageReceived(_ message: MessageBase) {
        // Forward the received message to the ChatDelegate
        self.delegate?.onNewMessage(message)
    }
    
    // Delegate method called when a message is removed
    public func onMessageRemoved(_ message: MessageBase) {
        // Forward the removed message to the ChatDelegate
        self.delegate?.onDeleteMessage(message)
    }
}
