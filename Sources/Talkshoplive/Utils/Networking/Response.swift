//
// Response.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

//MARK: - MessagingToken Response

/// A structure representing the response received when creating a messaging token.
public struct MessagingTokenResponse: Codable {
    let publishKey: String?
    let subscribeKey: String?
    let userId: String?
    let token: String?
    let channels: SubscribableChannel?
    let chatId: Int?

    enum CodingKeys: String, CodingKey {
        case publishKey = "publish_key"
        case subscribeKey = "subscribe_key"
        case userId = "user_id"
        case token
        case channels
        case chatId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        publishKey = try container.decodeIfPresent(String.self, forKey: .publishKey)
        subscribeKey = try container.decodeIfPresent(String.self, forKey: .subscribeKey)
        userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? container.decodeIfPresent(String.self, forKey: CodingKeys(rawValue: "userId")!)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        channels = try container.decodeIfPresent(SubscribableChannel.self, forKey: .channels)
        chatId = try container.decodeIfPresent(Int.self, forKey: .chatId)
    }
}

//MARK: - GetShows Response
public struct SubscribableChannel: Codable {
    let chat: String?
    let events: String?

    enum CodingKeys: String, CodingKey {
        case chat
        case events
    }
    
    // Default initializer for manual creation
    public init(chat: String?, events: String?) {
        self.chat = chat
        self.events = events
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        chat = try container.decodeIfPresent(String.self, forKey: .chat)
        events = try container.decodeIfPresent(String.self, forKey: .events)
    }
}

//MARK: - GetShows Response
public struct GetShowsResponse: Codable {
    let data : ShowData
}

//MARK: - No Response

public struct NoResponse: Codable {
    public init() {
        
    }
}

//MARK: - IncrementView Response

public struct IncrementViewResponse: Codable {
    let status: String?
    
    // MARK: Initializers
    public init() {
        status = nil
    }
    
    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case status
    }
    
    // Implement Decodable initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(String.self, forKey: .status)
    }
    
}

//MARK: - UserMeta Response

public struct UserMetaResponse: Codable {
    let sender: Sender?
    
    // MARK: Initializers
    public init() {
        sender = nil
    }
    
    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case sender
    }
    
    /// Implement Decodable initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sender = try container.decodeIfPresent(Sender.self, forKey: .sender)
    }
    
    /// Encodes this instance into the given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.sender, forKey: .sender)
    }
    
}

//MARK: - GetShoppettes Response
public struct GetShoppettesResponse: Codable {
    public let shoppettes: [ShoppettesData]
    public let meta: ShoppettesMeta
}

