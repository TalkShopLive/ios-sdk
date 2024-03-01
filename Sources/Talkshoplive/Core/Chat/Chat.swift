//
//  Chat.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

public protocol ChatDelegate: AnyObject {
    func onNewMessage(_ message: String)
    // Add more methods for other events if needed
}

public class Chat{
    // MARK: - Properties
    private let showKey: String
    private let mode: String
    private let refresh: String
    private let chatProvider: ChatProvider?
    public var delegate: ChatDelegate?

    
    // MARK: - Initializer
    
    public init(jwtToken:String,isGuest:Bool,showKey: String, mode: String, refresh: String) {
        // Initialize properties
        self.showKey = showKey
        self.mode = mode
        self.refresh = refresh

        self.chatProvider = ChatProvider(jwtToken: jwtToken, isGuest: isGuest,showKey: showKey)
        self.chatProvider?.delegate = self
    }
    
    public func sendMessage(message:String) {
        self.chatProvider?.publish(message: message)
    }
}

extension Chat : _ChatProviderDelegate {
    public func onMessageReceived(_ message: String) {
        self.delegate?.onNewMessage(message)
    }
}
