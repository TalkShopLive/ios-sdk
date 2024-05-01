//
//  EventData.swift
//
//
//  Created by TalkShoLive on 2024-01-30.
//

import Foundation

// MARK: - EventData 

/// Represents the data structure for an event.

public struct EventData: Codable {
    public var storeId: Int?
    public var name: String?
    public var status: String?
    public var duration: Int?
    public var hlsPlaybackUrl: String?
    public var hlsUrl: String?
    public var endedAt: String?
    public var streamInCloud: Bool?
    public var totalViews: Int?
    var id: Int?
    var productId: Int?
    var filename: String?
    var streamKey: String?
    var isTest: Bool?

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case productId = "product_id"
        case filename
        case name
        case status
        case streamKey = "stream_key"
        case duration = "duration"
        case hlsPlaybackUrl = "hls_playback_url"
        case isTest = "is_test"
        case endedAt
        case hlsUrl = "hls_url"
        case streamInCloud = "stream_in_cloud"
        case totalViews = "total_views"
    }
    
    // MARK: Initializers
        
    /// Default initializer to create an empty EventData instance.
    public init() {
        id = nil
        storeId = nil
        productId = nil
        filename = nil
        name = nil
        status = nil
        streamKey = nil
        duration = nil
        hlsPlaybackUrl = nil
        isTest = nil
        endedAt = nil
        hlsUrl = nil
        streamInCloud = false
        totalViews = nil
    }

    /// Custom initializer to create an instance of EventData from a decoder.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        storeId = try? container.decodeIfPresent(Int.self, forKey: .storeId)
        productId = try? container.decodeIfPresent(Int.self, forKey: .productId)
        filename = try? container.decodeIfPresent(String.self, forKey: .filename)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        status = try? container.decodeIfPresent(String.self, forKey: .status)
        streamKey = try? container.decodeIfPresent(String.self, forKey: .streamKey)
        duration = try? container.decodeIfPresent(Int.self, forKey: .duration)
        hlsPlaybackUrl = try? container.decodeIfPresent(String.self, forKey: .hlsPlaybackUrl)
        isTest = try? container.decodeIfPresent(Bool.self, forKey: .isTest)
        endedAt = try? container.decodeIfPresent(String.self, forKey: .endedAt)
        streamInCloud = try container.decodeIfPresent(Bool.self, forKey: .streamInCloud)
        totalViews = try? container.decodeIfPresent(Int.self, forKey: .totalViews)

        // Generate hlsUrl if filename is available
        if let fileName = filename {
            let url = APIEndpoint.getHlsUrl(fileName: fileName)
            hlsUrl = url.baseURL + url.path
        } else {
            hlsUrl = nil
        }
    }
}
