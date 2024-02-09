//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation

// Define the main struct representing the top-level data
public struct ShowData: Codable {
    public let id: Int?
    public let productKey: String?
    public let name: String?
    public let description: String?
    public let slug: String?
    public let brandName: String?
    public let currentEvent: Event?
    public let events: [Event]?
    
    // CodingKeys enum to map the JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case productKey = "product_key"
        case name
        case description
        case slug
        case brandName = "brand_name"
        case currentEvent = "current_event"
        case events
    }
    
    public init() {
        id = nil
        productKey = nil
        name = nil
        description = nil
        slug = nil
        brandName = nil
        currentEvent = nil
        events = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        productKey = try? container.decode(String.self, forKey: .productKey)
        name = try? container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        slug = try? container.decode(String.self, forKey: .slug)
        brandName = try? container.decode(String.self, forKey: .brandName)
        currentEvent = try? container.decode(Event.self, forKey: .currentEvent)
        events = try? container.decode([Event].self, forKey: .events)

    }
}
// Define a nested struct representing the "events" data
public struct Event: Codable {
    public let id: Int?
    let filename: String?
    let eventName: String?
    let status: String?
    let streamKey: String?
    let isTest: Bool?

    // CodingKeys enum to map the JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case filename
        case eventName = "name"
        case status
        case streamKey = "stream_key"
        case isTest = "is_test"
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        filename = try? container.decode(String.self, forKey: .filename)
        eventName = try? container.decode(String.self, forKey: .eventName)
        status = try? container.decode(String.self, forKey: .status)
        streamKey = try? container.decode(String.self, forKey: .streamKey)
        isTest = try? container.decode(Bool.self, forKey: .isTest)
    }
}
