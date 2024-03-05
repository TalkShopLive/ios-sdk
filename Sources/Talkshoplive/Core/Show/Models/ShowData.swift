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
    public var status: String?
    public let hls_playback_url: String?
    public let hls_url: String?
    public let trailer_url: String?
    public let air_date: String?
    public let event_id: Int?
    public let cc: String?
    public let ended_at: String?
    public let duration: Int?
    private let currentEvent: EventData?
    private let events: [EventData]?
    private let streamingContent: StreamingContent?
    
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
        case duration
        case currentEvent = "current_event"
        case events
        case streamingContent = "streaming_content"
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
        duration = nil
        currentEvent = nil
        events = nil
        streamingContent = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        show_key = try? container.decode(String.self, forKey: .show_key)
        name = try? container.decode(String.self, forKey: .name)
        description = try? container.decode(String.self, forKey: .description)
        currentEvent = try? container.decode(EventData.self, forKey: .currentEvent)
        events = try? container.decode([EventData].self, forKey: .events)
        air_date = try? container.decode(String.self, forKey: .air_date)
        streamingContent = try? container.decode(StreamingContent.self, forKey: .streamingContent)
        ended_at = currentEvent?.ended_at
        
        if currentEvent == nil {
            hls_playback_url = nil
            status = "created"
            duration = nil
        } else {
            hls_playback_url = currentEvent?.hls_playback_url
            status = currentEvent?.status
            duration = currentEvent?.duration
        }
        
        if let fileName = currentEvent?.filename {
            let url = APIEndpoint.getHlsUrl(fileName: fileName)
            hls_url = url.baseURL + url.path
        } else {
            hls_url = nil
        }
        
        trailer_url = streamingContent?.trailers?.first?.video
        event_id = streamingContent?.airDates?.first?.eventID
        
        if let fileName = currentEvent?.streamKey, currentEvent?.isTest == false {
            let captionUrl = APIEndpoint.getClosedCaptions(fileName: fileName)
            let fileNameURL = captionUrl.baseURL + captionUrl.path
            cc = fileNameURL
        } else {
            cc = nil
        }
        
    }
}

struct StreamingContent: Codable {
    let id: Int?
    let trailers: [Trailer]?
    let airDates: [AirDate]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case trailers
        case airDates = "air_dates"
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        trailers = try? container.decode([Trailer].self, forKey: .trailers)
        airDates = try? container.decode([AirDate].self, forKey: .airDates)
    }
}

struct Trailer: Codable {
    let id: Int?
    let video: String?  // Assuming you want to work with URLs for video
    
    private enum CodingKeys: String, CodingKey {
        case id
        case video
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        video = try? container.decode(String.self, forKey: .video)
    }
}

struct AirDate: Codable {
    let id: Int?
    let name: String?
    let eventID: Int? // Renamed for camelCase convention
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case eventID = "event_id"
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        eventID = try? container.decode(Int.self, forKey: .eventID)

    }
}
