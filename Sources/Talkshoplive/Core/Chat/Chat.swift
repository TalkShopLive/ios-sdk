//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation
import PubNub

public class Chat {

    // MARK: - Properties
    private let showKey: String
    private let mode: String
    private let refresh: String

    // MARK: - Initializer

    public init(jwtToken:String,isGuest:Bool,showKey: String, mode: String, refresh: String) {
        // Initialize properties
        self.showKey = showKey
        self.mode = mode
        self.refresh = refresh
        
        let _ = ChatProvider(jwtToken: jwtToken, isGuest: isGuest)
    }
}

