//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation

/*
 {
   createdAt: DATE,  // Date object
   id: EPOCH/UNIX TimeStamp, // in milliseconds
   sender: UUID, // User id we get from CMS after creating messaging token
   text: "MESSAGE STRING", // Max length is 200
   type: "comment/question/giphy", // either one - question if string contains "?"
   platform: "sdk",
 }
 */
public struct Message: Codable {
    public var id: Int? // Current Timeinterval
    public var createdAt: Date? //Current Date
    public var sender: String?
    public var text: String?
    public var type: MessageType
    public var platform: String?

    public enum MessageType: String, Codable {
        case comment
        case question
        case giphy
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt
        case sender
        case text
        case type
        case platform
    }
    
    public init(id: Int? = nil, createdAt: Date? = nil, sender: String? = nil, text: String? = nil, type: MessageType? = nil, platform: String? = nil) {
            self.id = id
            self.createdAt = createdAt
            self.sender = sender
            self.text = text
            self.type = type ?? .comment // Default value, adjust as needed
            self.platform = platform
        }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        sender = try container.decodeIfPresent(String.self, forKey: .sender)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        type = try container.decode(MessageType.self, forKey: .type)
        platform = try container.decodeIfPresent(String.self, forKey: .platform)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(sender, forKey: .sender)
        try container.encodeIfPresent(text, forKey: .text)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(platform, forKey: .platform)
    }
    
    public func toJSON(messageObject:Message) -> String? {
        // Encode the Message instance into JSON data
        do {
            // Encode the Message instance into JSON data
            let jsonData = try JSONEncoder().encode(messageObject)

            // Convert the JSON data to a JSON string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
               return jsonString
            }
        } catch {
            print("Error encoding message: \(error)")
            return nil
        }
    }
}
