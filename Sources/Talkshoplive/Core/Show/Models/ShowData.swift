//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation

//MARK: - StreamingContent Object

// Define the main struct representing the top-level data
public struct ShowData: Codable {
    public let id: Int?
    public let show_key: String?
    public let name: String?
    public let show_description: String?
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
    private let owningStore: OwningStore?
    private let master: Master?
    public let video_thumbnail_url: String?
    public let channel_logo: String?
    public let channel_name: String?
    public let trailer_duration: Int?
    
    // CodingKeys enum to map the JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case show_key = "product_key"
        case name
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
        case owningStore = "owning_store"
        case show_description = "description"
        case master
        case video_thumbnail_url
        case channel_logo
        case channel_name = "brand_name"
        case trailer_duration
    }
    
    public init() {
        id = nil
        show_key = nil
        name = nil
        show_description = nil
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
        owningStore = nil
        master = nil
        video_thumbnail_url = nil
        channel_logo = nil
        channel_name = nil
        trailer_duration = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        show_key = try? container.decode(String.self, forKey: .show_key)
        name = try? container.decode(String.self, forKey: .name)
        show_description = try? container.decode(String.self, forKey: .show_description)
        currentEvent = try? container.decode(EventData.self, forKey: .currentEvent)
        events = try? container.decode([EventData].self, forKey: .events)
        streamingContent = try? container.decode(StreamingContent.self, forKey: .streamingContent)
        owningStore = try? container.decode(OwningStore.self, forKey: .owningStore)
        master = try? container.decode(Master.self, forKey: .master)
        ended_at = currentEvent?.ended_at
        channel_name = try? container.decode(String.self, forKey: .channel_name)

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
        air_date = streamingContent?.airDates?.first?.date
        channel_logo = owningStore?.image?.attachment?.large
        video_thumbnail_url = master?.images?.first?.attachment?.large
        trailer_duration = streamingContent?.trailers?.first?.duration
        
        if let fileName = currentEvent?.streamKey, currentEvent?.isTest == false {
            let captionUrl = APIEndpoint.getClosedCaptions(fileName: fileName)
            let fileNameURL = captionUrl.baseURL + captionUrl.path
            cc = fileNameURL
        } else {
            cc = nil
        }
        
    }
}

//MARK: - StreamingContent Object

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

//MARK: - Trailer Object

struct Trailer: Codable {
    let id: Int?
    let video: String?
    let duration : Int?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case video
        case duration
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        video = try? container.decode(String.self, forKey: .video)
        duration = try? container.decode(Int.self, forKey: .duration)
    }
}

//MARK: - AirDate Object

struct AirDate: Codable {
    let id: Int?
    let name: String?
    let eventID: Int? // Renamed for camelCase convention
    let date: String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case eventID = "event_id"
        case date
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        eventID = try? container.decode(Int.self, forKey: .eventID)
        date = try? container.decode(String.self, forKey: .date)

    }
}

//MARK: - OwningStore Object

struct OwningStore : Codable {
    let id: Int?
    let name: String?
    let image: ImageAttachment?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        image = try? container.decode(ImageAttachment.self, forKey: .image)
    }
}

//MARK: - ImageAttachment Object

struct ImageAttachment : Codable {
    let id: Int?
    let attachmentContentType: String?
    let attachmentFileName: String?
    let attachment: AttachmentDetails?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case attachmentContentType = "attachment_content_type"
        case attachmentFileName = "attachment_file_name"
        case attachment
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        attachmentContentType = try? container.decode(String.self, forKey: .attachmentContentType)
        attachmentFileName = try? container.decode(String.self, forKey: .attachmentFileName)
        attachment = try? container.decode(AttachmentDetails.self, forKey: .attachment)
    }
}

//MARK: - AttachmentDetails Object

struct AttachmentDetails : Codable {
    let product: String?
    let large: String?
    
    private enum CodingKeys: String, CodingKey {
        case product
        case large
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        product = try? container.decode(String.self, forKey: .product)
        large = try? container.decode(String.self, forKey: .large)
    }
}

//MARK: - Master Object

struct Master : Codable {
    let id: Int?
    let images: [ImageAttachment]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case images
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        images = try? container.decode([ImageAttachment].self, forKey: .images)
    }
}

