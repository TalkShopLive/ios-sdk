//
// APIResponseModel.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

public struct MessagingTokenResponse: Codable {
    let publishKey: String
    let subscribeKey: String
    let userId: String
    let token: String
    
    // MARK: - Coding Keys
    
    /// Coding keys for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case publishKey = "publish_key"
        case subscribeKey = "subscribe_key"
        case userId = "user_id"
        case token
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        publishKey = try container.decode(String.self, forKey: .publishKey)
        subscribeKey = try container.decode(String.self, forKey: .subscribeKey)
        userId = try container.decode(String.self, forKey: .userId)
        token = try container.decode(String.self, forKey: .token)
    }
}

public struct GetShowsResponse: Codable {
    let product : ShowData
}

public struct NoResponse: Codable {
    public init() {
        
    }
}

public struct IncrementViewResponse: Codable {
    let status: String?
    
    public init() {
        status = nil
    }
    
    // Define CodingKeys to map keys to properties
    enum CodingKeys: String, CodingKey {
        case status
    }
    
    // Implement Decodable initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(String.self, forKey: .status)
    }
    
}

public struct UserMeataResponse: Codable {
    let sender: Sender?
    
    public init() {
        sender = nil
    }
    
    // Define CodingKeys to map keys to properties
    enum CodingKeys: String, CodingKey {
        case sender
    }
    
    // Implement Decodable initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sender = try container.decodeIfPresent(Sender.self, forKey: .sender)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.sender, forKey: .sender)
    }
    
}

