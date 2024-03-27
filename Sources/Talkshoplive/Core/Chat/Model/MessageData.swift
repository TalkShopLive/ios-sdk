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
    public var channel: String?
    public var subscription: String?
    public var published: String?
    public var messageType: MessageType?
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
        self.published = String(pubNubMessage.published)
        self.messageType = MessageType(rawValue: pubNubMessage.messageType.rawValue) ?? .unknown
        self.metaData = pubNubMessage.metadata?.jsonStringify
        self.actions = self.toMessageActions(actions: pubNubMessage.actions)
    }
    
    public func toMessageActions(actions: [PubNubMessageAction]) -> [MessageAction]{
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
        try container.encode(self.publisher, forKey: .publisher)
        try container.encode(self.channel, forKey: .channel)
        try container.encode(self.subscription, forKey: .subscription)
        try container.encode(self.published, forKey: .published)
        try container.encode(self.messageType, forKey: .messageType)
        try container.encode(self.actions, forKey: .actions)
        try container.encode(self.metaData, forKey: .metaData)
    }
    
    /// Decodes a MessageBase object from a given decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.payload = try container.decodeIfPresent(MessageData.self, forKey: .payload)
        self.publisher = try container.decodeIfPresent(String.self, forKey: .publisher)
        self.channel = try container.decodeIfPresent(String.self, forKey: .channel)
        self.subscription = try container.decodeIfPresent(String.self, forKey: .subscription)
        self.published = try container.decodeIfPresent(String.self, forKey: .published)
        self.messageType = try container.decodeIfPresent(MessageType.self, forKey: .messageType)
        self.actions = try container.decodeIfPresent([MessageAction].self, forKey: .actions)
        self.metaData = try container.decodeIfPresent(String.self, forKey: .metaData)
    }
}

// MARK: Sender Object
public struct Sender : JSONCodable{
    public let id: String? //User ID obtained from the backend after creating a messaging token.
    public let name: String?
    public let profileUrl: String?
    public let externalId: String?
    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case profileUrl
        case externalId
    }
    
    // MARK: - Initializers
    
    /// Default initializer with default values.
    public init() {
        self.id = nil
        self.name = nil
        self.profileUrl = nil
        self.externalId = nil
    }
    
    /// Custom initializer with parameters for all properties.
    public init(id: String? = nil, name: String? = nil, profileUrl:String? = nil,externalId:String? = nil) {
        self.id = id
        self.name = name
        self.profileUrl = profileUrl
        self.externalId = externalId
    }
    
    // MARK: - Codable
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        if let profileURL = try? container.decode(URL.self, forKey: .profileUrl) {
            profileUrl = profileURL.absoluteString
        } else {
            profileUrl = nil
        }
        externalId = try container.decodeIfPresent(String.self, forKey: .externalId)
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(profileUrl, forKey: .profileUrl)
        try container.encode(externalId, forKey: .externalId)

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
    public var type: MessageType? // Enum representing the MessageType. Use .question if the text contains "?".
    public var platform: String? // Platform identifier, e.g., "sdk".
    public var key: MessagePayloadKey? // Platform identifier, e.g., "sdk".
    public var timeToken: String?
    
    public enum MessagePayloadKey: Codable {
        case messageDeleted
        case custom(String) // Handle any custom message types
        // Add more cases as needed
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let rawValue = try? container.decode(String.self) {
                switch rawValue {
                case "message_deleted":
                    self = .messageDeleted
                default:
                    self = .custom(rawValue)
                }
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid payload key")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .messageDeleted:
                try container.encode("message_deleted")
            case .custom(let value):
                try container.encode(value)
            }
        }
        
        // Function to check equality
        public func isEqual(to other: MessagePayloadKey) -> Bool {
            switch (self, other) {
            case (.messageDeleted, .messageDeleted):
                return true
            case let (.custom(value1), .custom(value2)):
                return value1 == value2
            default:
                return false
            }
        }
    }
    
    /// Enum defining different types of messages.
    public enum MessageType: String, Codable {
        case comment
        case question
        case giphy
        
        public init(from decoder: Decoder) throws {
                let stringValue = try decoder.singleValueContainer().decode(String.self)
                self = MessageType(rawValue: stringValue.lowercased()) ?? .comment
        }
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
        case key
        case timeToken = "payload"
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
        self.key = nil
        self.timeToken = nil
    }
    
    /// Custom initializer with parameters for all properties.
    public init(id: Int? = nil, createdAt: String? = nil, sender: Sender? = nil, text: String? = nil, type: MessageType? = nil, platform: String? = nil,key: MessagePayloadKey? = nil, payload: String? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.sender = sender
        self.text = text
        self.type = type ?? .comment // Default value, adjust as needed
        self.platform = platform
        self.key = key
        self.timeToken = payload
    }
    
    // MARK: - Codable
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        type = try container.decodeIfPresent(MessageType.self, forKey: .type)
        platform = try container.decodeIfPresent(String.self, forKey: .platform)
        key = try container.decodeIfPresent(MessagePayloadKey.self, forKey: .key)
        timeToken = try container.decodeIfPresent(String.self, forKey: .timeToken)

        
        do {
            // Try to decode the "sender" key as a Sender object
            sender = try container.decodeIfPresent(Sender.self, forKey: .sender)
        } catch DecodingError.typeMismatch {
            // If decoding as Sender fails due to type mismatch (probably it's a String),
            // try to decode it as a String and create a Sender object with the provided value
            let senderString = try container.decodeIfPresent(String.self, forKey: .sender)
            sender = Sender(id: senderString, name: senderString)
        }
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(sender, forKey: .sender)
        try container.encode(text, forKey: .text)
        try container.encode(type, forKey: .type)
        try container.encode(platform, forKey: .platform)
        try container.encode(key, forKey: .key)
        try container.encode(timeToken, forKey: .timeToken)
    }
}


// MARK: MessagePage Class

public struct MessagePage: JSONCodable {
    
    // MARK: - Properties
    public var start: Int?
    public var limit: Int?

    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case start
        case limit
    }
    
    // MARK: - Initializers
    
    /// Default initializer with default values.
    public init() {
        self.start = nil
        self.limit = 25
    }
    
    /// Custom initializer with parameters for all properties.
    public init(start: Int? = nil, limit: Int? = 25) {
        self.start = start
        self.limit = limit
    }
    
    /// Custom initializer to create a MessagePage object from a PubNubBoundedPageBase.
    public init(page: PubNubBoundedPageBase) {
        self.start = page.start.map { Int($0) }
        self.limit = page.limit
    }
    
    // MARK: - Codable Protocol
    
    /// Decoder initializer for creating an instance from encoded data.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        start = try container.decode(Int.self, forKey: .start)
        limit = try container.decode(Int.self, forKey: .limit)
    }
    
    /// Encoder method to convert the struct to an encoded format.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(start, forKey: .start)
        try container.encode(limit, forKey: .limit)
    }
    
    /// Converts the MessagePage object to a PubNubBoundedPageBase object.
    func toPubNubBoundedPageBase() -> PubNubBoundedPageBase {
        return PubNubBoundedPageBase(start: UInt64(start ?? 0), limit: limit) ?? PubNubBoundedPageBase.init()!
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
    public init(action: PubNubMessageAction) {
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
        
        try container.encode(actionType, forKey: .actionType)
        try container.encode(actionValue, forKey: .actionValue)
        try container.encode(publisher, forKey: .publisher)
    }
    
}
