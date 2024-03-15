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
    public init(jwtToken: String, isGuest: Bool, showKey: String) {
        // Set the showKey property
        self.showKey = showKey
        
        // Initialize ChatProvider for handling chat functionality using JWT Token
        self.chatProvider = ChatProvider(jwtToken: jwtToken, isGuest: isGuest, showKey: showKey)
        
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
    public func sendMessage(message: String) {
        // Call the publish method in ChatProvider to send the message
        self.chatProvider?.publish(message: message)
    }
    
    // Method to retrieve chat messages, optionally specifying a page for pagination.
    public func getChatMessages(limit: Int? = 25, start: Int? = nil, includeActions:Bool = true, includeMeta:Bool = true, includeUUID:Bool = true, completion: @escaping (Result<([MessageBase], MessagePage?), Error>) -> Void) {
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
}

// MARK: - Chat Extension

// Extend Chat to conform to _ChatProviderDelegate for handling messages received from ChatProvider
extension Chat: _ChatProviderDelegate {
    // Delegate method called when a new message is received
    public func onMessageReceived(_ message: MessageBase) {
        // Forward the received message to the ChatDelegate
        self.delegate?.onNewMessage(message)
    }
}
