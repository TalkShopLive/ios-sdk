//
//  ShowData.swift
//
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation

//MARK: - ShowData 

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
    public let currentEvent: EventData?
    public let videoThumbnailUrl: String?
    public let channelLogo: String?
    public let channelName: String?
    public let trailerDuration: Int?
    private let events: [EventData]?
    private let streamingContent: StreamingContent?
    private let owningStore: OwningStore?
    private let master: Master?

    
    // MARK: Coding Keys
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
    
    // MARK: Initializers
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
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        showKey = try? container.decodeIfPresent(String.self, forKey: .showKey)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        showDescription = try? container.decodeIfPresent(String.self, forKey: .showDescription)
        currentEvent = try? container.decodeIfPresent(EventData.self, forKey: .currentEvent)
        events = try? container.decodeIfPresent([EventData].self, forKey: .events)
        streamingContent = try? container.decodeIfPresent(StreamingContent.self, forKey: .streamingContent)
        owningStore = try? container.decodeIfPresent(OwningStore.self, forKey: .owningStore)
        master = try? container.decodeIfPresent(Master.self, forKey: .master)
        endedAt = currentEvent?.endedAt
        channelName = try? container.decodeIfPresent(String.self, forKey: .channelName)

        // If there is no current event, set playback URL, status, and duration to nil.
        if currentEvent == nil {
            hlsPlaybackUrl = nil
            status = "created"
            duration = nil
        } else {
            // If there is a current event, assign its playback URL, status, and duration.
            hlsPlaybackUrl = currentEvent?.hlsPlaybackUrl
            status = currentEvent?.status
            duration = currentEvent?.duration
        }
        
        // Check if the current event's filename is available.
        if let fileName = currentEvent?.filename {
            // If filename exists, construct the HLS URL using the filename.
            let url = APIEndpoint.getHlsUrl(fileName: fileName)
            hlsUrl = url.baseURL + url.path
        } else {
            // If filename is not available, set the HLS URL to nil.
            hlsUrl = nil
        }
        
        trailerUrl = streamingContent?.trailers?.first?.video
        eventId = streamingContent?.airDates?.first?.eventID
        airDate = streamingContent?.airDates?.first?.date
        channelLogo = owningStore?.image?.attachment?.large
        videoThumbnailUrl = master?.images?.first?.attachment?.large
        trailerDuration = streamingContent?.trailers?.first?.duration
        
        // Check if the current event's stream key is available and if it's not a test event.
        if let fileName = currentEvent?.streamKey, currentEvent?.isTest == false {
            // If stream key exists and it's not a test event, retrieve closed captions URL.
            let captionUrl = APIEndpoint.getClosedCaptions(fileName: fileName)
            let fileNameURL = captionUrl.baseURL + captionUrl.path
            cc = fileNameURL
        } else {
            // If stream key is not available or it's a test event, set closed captions URL to nil.
            cc = nil
        }
        
    }
}

//MARK: - StreamingContent Object

struct StreamingContent: Codable {
    let id: Int?
    let trailers: [Trailer]?
    let airDates: [AirDate]?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case trailers
        case airDates = "air_dates"
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        trailers = try? container.decodeIfPresent([Trailer].self, forKey: .trailers)
        airDates = try? container.decodeIfPresent([AirDate].self, forKey: .airDates)
    }
}

//MARK: - Trailer Object

struct Trailer: Codable {
    let id: Int?
    let video: String?
    let duration : Int?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case video
        case duration
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        video = try? container.decodeIfPresent(String.self, forKey: .video)
        duration = try? container.decodeIfPresent(Int.self, forKey: .duration)
    }
}

//MARK: - AirDate Object

struct AirDate: Codable {
    let id: Int?
    let name: String?
    let eventID: Int? // Renamed for camelCase convention
    let date: String?
    
    // MARK: Coding Keys
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
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        eventID = try? container.decodeIfPresent(Int.self, forKey: .eventID)
        date = try? container.decodeIfPresent(String.self, forKey: .date)

    }
}

//MARK: - OwningStore Object

struct OwningStore : Codable {
    let id: Int?
    let name: String?
    let image: ImageAttachment?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case image
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        image = try? container.decodeIfPresent(ImageAttachment.self, forKey: .image)
    }
}

//MARK: - ImageAttachment Object

struct ImageAttachment : Codable {
    let id: Int?
    let attachmentContentType: String?
    let attachmentFileName: String?
    let attachment: AttachmentDetails?
    
    // MARK: Coding Keys
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
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        attachmentContentType = try? container.decodeIfPresent(String.self, forKey: .attachmentContentType)
        attachmentFileName = try? container.decodeIfPresent(String.self, forKey: .attachmentFileName)
        attachment = try? container.decodeIfPresent(AttachmentDetails.self, forKey: .attachment)
    }
}

//MARK: - AttachmentDetails Object

struct AttachmentDetails : Codable {
    let product: String?
    let large: String?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case product
        case large
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        product = try? container.decodeIfPresent(String.self, forKey: .product)
        large = try? container.decodeIfPresent(String.self, forKey: .large)
    }
}

//MARK: - Master Object

struct Master : Codable {
    let id: Int?
    let images: [ImageAttachment]?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case images
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        images = try? container.decodeIfPresent([ImageAttachment].self, forKey: .images)
    }
}

