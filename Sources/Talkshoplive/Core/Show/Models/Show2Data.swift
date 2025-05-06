//
//  File.swift
//  Talkshoplive
//
//  Created by Mayuri Patel on 2025-04-22.
//

import Foundation

public struct Show2Data: Codable {
    
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
        case hlsPlaybackUrl, hlsUrl, trailerUrl, cc, eventId, duration, trailerDuration,videoThumbnailUrl
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
        
        channel = try? container.decodeIfPresent(Channel.self, forKey: .channel)
        channelLogo = channel?.thumbnailImage
        channelName = channel?.name
        
        showProducts = try? container.decodeIfPresent([ShowProduct].self, forKey: .showProducts)
        entranceProductsIds = try? container.decodeIfPresent([ShowProduct].self, forKey: .showProducts)?
            .filter { $0.kind == "entrance" }
            .map { $0.productId }
        
        assets = try? container.decodeIfPresent([Asset].self, forKey: .assets)
        
        hlsPlaybackUrl = assets?.first(where: { $0.type == .live })?.url
        hlsUrl = assets?.first(where: { $0.type == .vod})?.url
        trailerUrl = assets?.first(where: { $0.type == .trailer })?.url
        
        if let vodUrl = hlsUrl {
            cc = vodUrl.replacingOccurrences(of: "mp4", with: "transcript.vtt")
        } else {
            cc = nil
        }
        
        eventId = assets?.first?.id.intValue
        duration = assets?.first(where: { $0.type == .vod })?.duration
        trailerDuration = assets?.first(where: { $0.type == .trailer })?.duration
        videoThumbnailUrl = assets?.first(where: { $0.thumbnailImageUrl != nil })?.thumbnailImageUrl
        
    }
}

public struct Channel: Codable {
    
    let id: Int?
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
