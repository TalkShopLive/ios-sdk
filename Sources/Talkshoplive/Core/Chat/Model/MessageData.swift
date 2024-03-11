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
    public var actions: [MessageAction]?
    public var metaData: String?
    
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
        case actions
        case metaData
    }
    
    /// Default initializer with all properties set to nil or default values.
    public init() {
        publisher = nil
        channel = nil
        subscription = nil
        published = nil
        messageType = .unknown
        payload = nil
        actions = nil
        metaData = nil
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
        self.metaData = pubNubMessage.metadata?.jsonStringify
        self.actions = self.toMessageActions(actions: pubNubMessage.actions)
    }
    
    public func toMessageActions(actions : [PubNubMessageAction]) -> [MessageAction]{
        var actionsArray = [MessageAction]()
        for i in actions {
            let actionObject = MessageAction(action: i)
            actionsArray.append(actionObject)
        }
        return actionsArray
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
        try container.encode(self.actions, forKey: .actions)
        try container.encode(self.metaData, forKey: .metaData)
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
        self.actions = try container.decode([MessageAction].self, forKey: .actions)
        self.metaData = try container.decode(String.self, forKey: .metaData)
    }
}

// MARK: Sender Object
public struct Sender : JSONCodable{
    let id: String? //User ID obtained from the backend after creating a messaging token.
    public let name: String?
    
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

public struct MessagePage: JSONCodable {
    
    // MARK: - Properties
    public var limit: Int?

    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case limit
    }
    
    // MARK: - Initializers
    
    /// Default initializer with default values.
    public init() {
        self.limit = 100
    }
    
    /// Custom initializer with parameters for all properties.
    public init(limit: Int? = 100) {
        self.limit = limit
    }
    
    /// Custom initializer to create a MessagePage object from a PubNubBoundedPageBase.
    public init(page : PubNubBoundedPageBase) {
        self.limit = page.limit
    }
    
    // MARK: - Codable Protocol
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(limit, forKey: .limit)
    }
    
    /// Converts the MessagePage object to a PubNubBoundedPageBase object.
    func toPubNubBoundedPageBase() -> PubNubBoundedPageBase {
        return PubNubBoundedPageBase(limit: limit) ?? PubNubBoundedPageBase.init()!
    }
}

public struct MessageAction : JSONCodable{
   
    // MARK: - Properties
    public var actionType: String?
    public var actionValue: String?
    public var actionTimetoken: Int?
    public var publisher: String?
    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case actionType
        case actionValue
        case actionTimetoken
        case publisher
    }
    
    // MARK: - Initializers
    
    /// Default initializer with default values.
    public init() {
        actionType = nil
        actionValue = nil
        actionTimetoken = nil
        publisher = nil
    }
    
    /// Custom initializer to create a MessagePage object from a PubNubBoundedPageBase.
    public init(action : PubNubMessageAction) {
        actionType = action.actionType
        actionValue = action.actionValue
        actionTimetoken = Int(action.actionTimetoken)
        publisher = action.publisher
    }
    
    // MARK: - Codable Protocol
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        actionType = try container.decodeIfPresent(String.self, forKey: .actionType)
        actionValue = try container.decodeIfPresent(String.self, forKey: .actionValue)
        actionTimetoken = try container.decodeIfPresent(Int.self, forKey: .actionTimetoken)
        publisher = try container.decodeIfPresent(String.self, forKey: .publisher)
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(actionType, forKey: .actionType)
        try container.encodeIfPresent(actionValue, forKey: .actionValue)
        try container.encodeIfPresent(publisher, forKey: .publisher)
    }
    
}
