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
    public let show_key: String?
    public let name: String?
    public let description: String?
    public let status: String?
    public let hls_playback_url: String?
    public let hls_url: String?
    public let trailer_url: String?
    public let air_date: String?
    public let event_id: Int?
    public let cc: String?
    public let ended_at: String?
    private let currentEvent: Event?
    private let events: [Event]?
    
    // CodingKeys enum to map the JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case show_key = "product_key"
        case name
        case description
        case status
        case hls_playback_url
        case hls_url
        case trailer_url
        case air_date
        case event_id
        case cc
        case ended_at
        case currentEvent = "current_event"
        case events
    }
    
    public init() {
        id = nil
        show_key = nil
        name = nil
        description = nil
        status = nil
        hls_playback_url = nil
        hls_url = nil
        trailer_url = nil
        air_date = nil
        event_id = nil
        cc = nil
        ended_at = nil
        currentEvent = nil
        events = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        show_key = try? container.decode(String.self, forKey: .show_key)
        name = try? container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        currentEvent = try? container.decode(Event.self, forKey: .currentEvent)
        events = try? container.decode([Event].self, forKey: .events)
        status = currentEvent?.status
        hls_playback_url = currentEvent?.hls_playback_url
        hls_url = try? container.decode(String.self, forKey: .hls_url)
        trailer_url = try? container.decode(String.self, forKey: .trailer_url)
        air_date = try? container.decode(String.self, forKey: .air_date)
        event_id = currentEvent?.id
        ended_at = currentEvent?.ended_at
        
        if let fileName = currentEvent?.streamKey, currentEvent?.isTest == false {
            let captionUrl = APIEndpoint.getClosedCaptions(fileName: fileName)
            let fileNameURL = captionUrl.baseURL + captionUrl.path
            cc = fileNameURL
        } else {
            cc = nil
        }
    }
}
// Define a nested struct representing the "events" data
public struct Event: Codable {
    let id: Int?
    let filename: String?
    let eventName: String?
    let status: String?
    let streamKey: String?
    let isTest: Bool?
    let hls_playback_url: String?
    let ended_at: String?

    // CodingKeys enum to map the JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case filename
        case eventName = "name"
        case status
        case streamKey = "stream_key"
        case isTest = "is_test"
        case hls_playback_url
        case ended_at
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
        hls_playback_url = try? container.decode(String.self, forKey: .hls_playback_url)
        ended_at = try? container.decode(String.self, forKey: .ended_at)

    }
}
