//
//  MessageDataModel.swift
//
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation
import PubNub

// MARK: Base Class

public struct MessageBase: JSONCodable {
    
    public var publisher: String?
    var channel: String?
    var subscription: String?
    var published: String?
    public var messageType: MessageType
    public var payload: MessageData?
    
    // MARK: - Enums
    
    /// Enum representing the type of the message.
    public enum MessageType: Int, Codable, Hashable {
      case message = 0
      case signal = 1
      case object = 2
      case messageAction = 3
      case file = 4
      case unknown = 999
    }
    
    // MARK: - CodingKeys
    
    /// Enum defining the coding keys for encoding and decoding.
    enum CodingKeys: CodingKey {
        case payload
        case publisher
        case concreteMessageActions
        case channel
        case subscription
        case published
        case concreteMetadata
        case messageType
    }
    
    /// Default initializer with all properties set to nil or default values.
    public init() {
        publisher = nil
        channel = nil
        subscription = nil
        published = nil
        messageType = .unknown
        payload = nil
    }
    
    /// Custom initializer to create a MessageBase object with specified values.
    public init(
        payload: MessageData,
        publisher: String?,
        channel: String,
        subscription: String?,
        published: String,
        messageType: MessageType = .unknown
    ) {
        self.payload = payload
        self.publisher = publisher
        self.channel = channel
        self.subscription = subscription
        self.published = published
        self.messageType = messageType
    }
    
    /// Custom initializer to create a MessageBase object from a PubNubMessage.
    public init(pubNubMessage: PubNubMessage) {
        if let payloadString = pubNubMessage.payload.jsonStringify {
            if let payload = convertToModel(from: payloadString, responseType: MessageData.self) {
                self.payload = payload
            }
        }
        self.publisher = pubNubMessage.publisher
        self.channel = pubNubMessage.channel
        self.subscription = pubNubMessage.subscription
        self.published = pubNubMessage.published.description.jsonStringify
        self.messageType = MessageType(rawValue: pubNubMessage.messageType.rawValue) ?? .unknown
    }
    
    // MARK: - Codable
    
    /// Encodes the MessageBase object to a given encoder.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.payload, forKey: .payload)
        try container.encodeIfPresent(self.publisher, forKey: .publisher)
        try container.encode(self.channel, forKey: .channel)
        try container.encodeIfPresent(self.subscription, forKey: .subscription)
        try container.encode(self.published, forKey: .published)
        try container.encode(self.messageType, forKey: .messageType)
    }
    
    /// Decodes a MessageBase object from a given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.payload = try container.decode(MessageData.self, forKey: .payload)
        self.publisher = try container.decodeIfPresent(String.self, forKey: .publisher)
        self.channel = try container.decode(String.self, forKey: .channel)
        self.subscription = try container.decodeIfPresent(String.self, forKey: .subscription)
        self.published = try container.decode(String.self, forKey: .published)
        self.messageType = try container.decode(MessageType.self, forKey: .messageType)
    }
}

// MARK: Sender Object
public struct Sender : JSONCodable{
    let id: String? //User ID obtained from the backend after creating a messaging token.
    let name: String?
    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
    
    // MARK: - Initializers
    
    /// Default initializer with default values.
    public init() {
        self.id = nil
        self.name = nil
    }
    
    /// Custom initializer with parameters for all properties.
    public init(id: String? = nil, name: String? = nil) {
        self.id = id
        self.name = name
    }
    
    // MARK: - Codable
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
    }
}

// MARK: Message Data Class

/// A struct representing the data structure for chat messages.
public struct MessageData: JSONCodable {
    
    // MARK: - Properties
    
    public var id: Int? // Represents the current date converted to String.
    public var createdAt: String? // Represents the current timestamp in seconds.
    public var sender: Sender? //
    public var text: String? //The message to be sent.
    public var type: MessageType // Enum representing the MessageType. Use .question if the text contains "?".
    public var platform: String? // Platform identifier, e.g., "sdk".
    
    /// Enum defining different types of messages.
    public enum MessageType: String, Codable {
        case comment
        case question
        case giphy
    }

    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case sender
        case text
        case type
        case platform
    }
    
    // MARK: - Initializers
    
    /// Default initializer with default values.
    public init() {
        self.id = nil
        self.createdAt = nil
        self.sender = nil
        self.text = nil
        self.type = .comment // Default value, adjust as needed
        self.platform = nil
    }
    
    /// Custom initializer with parameters for all properties.
    public init(id: Int? = nil, createdAt: String? = nil, sender: Sender? = nil, text: String? = nil, type: MessageType? = nil, platform: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.sender = sender
        self.text = text
        self.type = type ?? .comment // Default value, adjust as needed
        self.platform = platform
    }
    
    // MARK: - Codable
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        sender = try container.decodeIfPresent(Sender.self, forKey: .sender)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        type = try container.decode(MessageType.self, forKey: .type)
        platform = try container.decodeIfPresent(String.self, forKey: .platform)
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(platform, forKey: .platform)
    }
}


// MARK: MessagePage Class

/// Represents a page of chat messages for pagination purposes, conforming to the JSONCodable protocol.
public struct MessagePage: JSONCodable {
    
    // MARK: - Properties
    
    public var start: Int?
    public var end: Int?
    public var limit: Int?

    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case start
        case end
        case limit
    }
    
    // MARK: - Initializers
    
    /// Default initializer with default values.
    public init() {
        self.start = nil
        self.end = nil
        self.limit = nil
    }
    
    /// Custom initializer with parameters for all properties.
    public init(start: Int? = nil, end: Int? = nil, limit: Int? = nil) {
        self.start = start
        self.end = end
        self.limit = limit
    }
    
    /// Custom initializer to create a MessagePage object from a PubNubBoundedPageBase.
    public init(page : PubNubBoundedPageBase) {
        self.start = page.start.map { Int($0) }
        self.end = page.end.map { Int($0) }
        self.limit = page.limit
    }
    
    // MARK: - Codable Protocol
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        start = try container.decodeIfPresent(Int.self, forKey: .start)
        end = try container.decodeIfPresent(Int.self, forKey: .end)
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(start, forKey: .start)
        try container.encodeIfPresent(end, forKey: .end)
        try container.encodeIfPresent(limit, forKey: .limit)
    }
    
    /// Converts the MessagePage object to a PubNubBoundedPageBase object.
    func toPubNubBoundedPageBase() -> PubNubBoundedPageBase {
        return PubNubBoundedPageBase(start: UInt64(start ?? 0), end: UInt64(end ?? 0), limit: limit) ?? PubNubBoundedPageBase.init()!
    }
}
