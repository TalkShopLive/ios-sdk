//
//  File.swift
//  
//
//  Created by TalkShoLive on 2024-01-30.
//

import Foundation

public struct EventData: Codable {
    var id: Int?
    var storeId: Int?
    var productId: Int?
    var createdAt: Date?
    var updatedAt: Date?
    var startedAt: Date?
    var endedAt: Date?
    var duration: Int?
    var maxDuration: Int?
    var productExpirationTime: TimeInterval?
    var filename: String?
    public var name: String?
    public var status: String?
    var isFlagged: Bool?
    var totalViews: Int?
    var streamKey: String?
    var platform: String?
    var jwVideoKey: String?
    var hlsPlaybackURL: URL?
    var streamInCloud: Bool?
    var vveSupported: Bool?
    var totalViewsEmbed: Int?
    var isTest: Bool?
    var durationFormatted: String?
    var hostSourceId: Int?
    var legacyChat: Bool?
    var currentStreamStatus: String?
    var userId: Int?
    var disconnectedAt: Date?
    var isExpired: Bool?
    var tags: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case productId = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case duration
        case maxDuration = "max_duration"
        case productExpirationTime = "product_expiration_time"
        case filename
        case name
        case status
        case isFlagged = "is_flagged"
        case totalViews = "total_views"
        case streamKey = "stream_key"
        case platform
        case jwVideoKey = "jw_video_key"
        case hlsPlaybackURL = "hls_playback_url"
        case streamInCloud = "stream_in_cloud"
        case vveSupported = "vve_supported"
        case totalViewsEmbed = "total_views_embed"
        case isTest = "is_test"
        case durationFormatted = "duration_formatted"
        case hostSourceId = "host_source_id"
        case legacyChat = "legacy_chat"
        case currentStreamStatus = "current_stream_status"
        case userId = "user_id"
        case disconnectedAt = "disconnected_at"
        case isExpired = "is_expired"
        case tags
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decode(Int.self, forKey: .id)
        storeId = try? container.decode(Int.self, forKey: .storeId)
        productId = try? container.decode(Int.self, forKey: .productId)
        createdAt = try? container.decode(Date.self, forKey: .createdAt)
        updatedAt = try? container.decode(Date.self, forKey: .updatedAt)
        startedAt = try? container.decode(Date.self, forKey: .startedAt)
        endedAt = try? container.decode(Date.self, forKey: .endedAt)
        duration = try? container.decode(Int.self, forKey: .duration)
        maxDuration = try? container.decode(Int.self, forKey: .maxDuration)
        productExpirationTime = try? container.decode(TimeInterval.self, forKey: .productExpirationTime)
        filename = try? container.decode(String.self, forKey: .filename)
        name = try? container.decode(String.self, forKey: .name)
        status = try? container.decode(String.self, forKey: .status)
        isFlagged = try? container.decode(Bool.self, forKey: .isFlagged)
        totalViews = try? container.decode(Int.self, forKey: .totalViews)
        streamKey = try? container.decode(String.self, forKey: .streamKey)
        platform = try? container.decode(String.self, forKey: .platform)
        jwVideoKey = try? container.decode(String.self, forKey: .jwVideoKey)
        hlsPlaybackURL = try? container.decode(URL.self, forKey: .hlsPlaybackURL)
        streamInCloud = try? container.decode(Bool.self, forKey: .streamInCloud)
        vveSupported = try? container.decode(Bool.self, forKey: .vveSupported)
        totalViewsEmbed = try? container.decode(Int.self, forKey: .totalViewsEmbed)
        isTest = try? container.decode(Bool.self, forKey: .isTest)
        durationFormatted = try? container.decode(String.self, forKey: .durationFormatted)
        hostSourceId = try? container.decode(Int.self, forKey: .hostSourceId)
        legacyChat = try? container.decode(Bool.self, forKey: .legacyChat)
        currentStreamStatus = try? container.decode(String.self, forKey: .currentStreamStatus)
        userId = try? container.decode(Int.self, forKey: .userId)
        disconnectedAt = try? container.decode(Date.self, forKey: .disconnectedAt)
        isExpired = try? container.decode(Bool.self, forKey: .isExpired)
        tags = try? container.decode([String].self, forKey: .tags)
    }
}
