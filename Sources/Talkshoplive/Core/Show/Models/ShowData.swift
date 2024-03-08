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
    public let showKey: String?
    public let name: String?
    public let showDescription: String?
    public var status: String?
    public let hlsPlaybackUrl: String?
    public let hlsUrl: String?
    public let trailerUrl: String?
    public let airDate: String?
    public let eventId: Int?
    public let cc: String?
    public let endedAt: String?
    public let duration: Int?
    private let currentEvent: EventData?
    private let events: [EventData]?
    private let streamingContent: StreamingContent?
    private let owningStore: OwningStore?
    private let master: Master?
    public let videoThumbnailUrl: String?
    public let channelLogo: String?
    public let channelName: String?
    public let trailerDuration: Int?
    
    // CodingKeys enum to map the JSON keys to Swift property names
    enum CodingKeys: String, CodingKey {
        case id
        case showKey = "product_key"
        case name
        case status
        case hlsPlaybackUrl
        case hlsUrl
        case trailerUrl
        case airDate
        case eventId
        case cc
        case endedAt
        case duration
        case currentEvent = "current_event"
        case events
        case streamingContent = "streaming_content"
        case owningStore = "owning_store"
        case showDescription = "description"
        case master
        case videoThumbnailUrl
        case channelLogo
        case channelName = "brand_name"
        case trailerDuration
    }
    
    public init() {
        id = nil
        showKey = nil
        name = nil
        showDescription = nil
        status = nil
        hlsPlaybackUrl = nil
        hlsUrl = nil
        trailerUrl = nil
        airDate = nil
        eventId = nil
        cc = nil
        endedAt = nil
        duration = nil
        currentEvent = nil
        events = nil
        streamingContent = nil
        owningStore = nil
        master = nil
        videoThumbnailUrl = nil
        channelLogo = nil
        channelName = nil
        trailerDuration = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decode(Int.self, forKey: .id)
        showKey = try? container.decode(String.self, forKey: .showKey)
        name = try? container.decode(String.self, forKey: .name)
        showDescription = try? container.decode(String.self, forKey: .showDescription)
        currentEvent = try? container.decode(EventData.self, forKey: .currentEvent)
        events = try? container.decode([EventData].self, forKey: .events)
        streamingContent = try? container.decode(StreamingContent.self, forKey: .streamingContent)
        owningStore = try? container.decode(OwningStore.self, forKey: .owningStore)
        master = try? container.decode(Master.self, forKey: .master)
        endedAt = currentEvent?.endedAt
        channelName = try? container.decode(String.self, forKey: .channelName)

        if currentEvent == nil {
            hlsPlaybackUrl = nil
            status = "created"
            duration = nil
        } else {
            hlsPlaybackUrl = currentEvent?.hlsPlaybackUrl
            status = currentEvent?.status
            duration = currentEvent?.duration
        }
        
        if let fileName = currentEvent?.filename {
            let url = APIEndpoint.getHlsUrl(fileName: fileName)
            hlsUrl = url.baseURL + url.path
        } else {
            hlsUrl = nil
        }
        
        trailerUrl = streamingContent?.trailers?.first?.video
        eventId = streamingContent?.airDates?.first?.eventID
        airDate = streamingContent?.airDates?.first?.date
        channelLogo = owningStore?.image?.attachment?.large
        videoThumbnailUrl = master?.images?.first?.attachment?.large
        trailerDuration = streamingContent?.trailers?.first?.duration
        
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

