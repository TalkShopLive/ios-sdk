//
//  ShowData.swift
//
//
//  Created by TalkShopLive on 2024-01-30.
//

import Foundation

public struct ShowData: Codable {
    
    public let id: Int?
    public let showKey: String?
    public let name: String?
    public let showDescription: String?
    public var status: String?
    public let airDate: String?
    public let endedAt: String?
    public let productsIds: [Int]?
    public let channelLogo: String?
    public let channelName: String?
    public let channelId: Int?
    let channel:Channel?
    public let entranceProductsIds: [Int]?
    private let showProducts : [ShowProduct]?
    private let assets: [Asset]?
    
    public let hlsPlaybackUrl: String?
    public let hlsUrl: String?
    public let trailerUrl: String?
    public let cc: String?
    public let eventId: Int?
    public let duration: Int?
    public let trailerDuration: Int?
    public let videoThumbnailUrl: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case showKey = "key"
        case name = "title"
        case showDescription = "description"
        case status = "state"
        case airDate = "scheduled_live_at"
        case endedAt = "ended_at"
        case productsIds = "show_product_ids"
        case channelLogo,channelName,channel
        case showProducts = "show_products",entranceProductsIds
        case assets
        case hlsPlaybackUrl, hlsUrl, trailerUrl, cc, eventId, duration, trailerDuration
        case videoThumbnailUrl = "thumbnail_image"
        case channelId
    }
    
    // MARK: Initializers
    public init() {
        id = nil
        showKey = nil
        name = nil
        showDescription = nil
        status = nil
        airDate = nil
        endedAt = nil
        productsIds = nil
        channelLogo = nil
        channelName = nil
        channel = nil
        showProducts = nil
        entranceProductsIds = nil
        assets = nil
        hlsPlaybackUrl = nil
        hlsUrl = nil
        trailerUrl = nil
        cc = nil
        eventId = nil
        duration = nil
        trailerDuration = nil
        videoThumbnailUrl = nil
        channelId = nil
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        showKey = try? container.decodeIfPresent(String.self, forKey: .showKey)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        showDescription = try? container.decodeIfPresent(String.self, forKey: .showDescription)
        status = try? container.decodeIfPresent(String.self, forKey: .status)
        airDate = try? container.decodeIfPresent(String.self, forKey: .airDate)
        endedAt = try? container.decodeIfPresent(String.self, forKey: .endedAt)
        productsIds = try? container.decodeIfPresent([Int].self, forKey: .productsIds)
        videoThumbnailUrl = try? container.decodeIfPresent(String.self, forKey: .videoThumbnailUrl)
        
        channel = try? container.decodeIfPresent(Channel.self, forKey: .channel)
        channelLogo = channel?.thumbnailImage
        channelName = channel?.name
        channelId = channel?.id
        
        showProducts = try? container.decodeIfPresent([ShowProduct].self, forKey: .showProducts)
        entranceProductsIds = try? container.decodeIfPresent([ShowProduct].self, forKey: .showProducts)?
            .filter { $0.kind == "entrance" }
            .map { $0.productId }
        
        do {
            assets = try container.decodeIfPresent([Asset].self, forKey: .assets)
        } catch {
            Config.shared.isDebugMode() ? print("Failed to decode assets: \(error)") : ()
            assets = nil
        }
        
        hlsPlaybackUrl = assets?.first(where: { $0.type == .live })?.url
        hlsUrl = assets?.first(where: { $0.type == .vod})?.url
        trailerUrl = assets?.first(where: { $0.type == .trailer })?.url
        
        if let vodUrl = hlsUrl {
            cc = vodUrl.replacingOccurrences(of: "mp4", with: "transcript.vtt")
        } else {
            cc = nil
        }
        
        eventId = assets?.first?.id ?? nil
        duration = assets?.first(where: { $0.type == .vod })?.duration
        trailerDuration = assets?.first(where: { $0.type == .trailer })?.duration        
    }
}

public struct Channel: Codable {
    
    public let id: Int?
    public let name: String?
    public let code: String?
    public let thumbnailImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case code
        case thumbnailImage = "thumbnail_image"
    }
    
    // MARK: - Initializers
    public init() {
        id = nil
        name = nil
        code = nil
        thumbnailImage = nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        code = try? container.decodeIfPresent(String.self, forKey: .code)
        thumbnailImage = try? container.decodeIfPresent(String.self, forKey: .thumbnailImage)
    }
}

struct ShowProduct: Codable {
    let productId: Int
    let kind: String
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case kind
    }
}

//MARK: - ImageAttachment Object

public struct ImageAttachment : Codable {
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
    let original: String?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case product
        case large
        case original
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        product = try? container.decodeIfPresent(String.self, forKey: .product)
        large = try? container.decodeIfPresent(String.self, forKey: .large)
        original = try? container.decodeIfPresent(String.self, forKey: .original)
    }
}

//MARK: - Master Object

struct Master : Codable {
    let id: Int?
    let sku: String?
    let images: [ImageAttachment]?
    
    // MARK: Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case images
        case sku
    }
    
    // Custom initializer to handle decoding from JSON
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode each property and use nil coalescing to handle optional values
        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        images = try? container.decodeIfPresent([ImageAttachment].self, forKey: .images)
        sku = try? container.decodeIfPresent(String.self, forKey: .sku)
    }
}

