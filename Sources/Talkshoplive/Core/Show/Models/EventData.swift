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
    var filename: String?
    public var name: String?
    public var status: String?
    var streamKey: String?
    var hlsPlaybackURL: URL?
    var isTest: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case productId = "product_id"
        case filename
        case name
        case status
        case streamKey = "stream_key"
        case hlsPlaybackURL = "hls_playback_url"
        case isTest = "is_test"
    }
    
    public init() {
        id = nil
        storeId = nil
        productId = nil
        filename = nil
        name = nil
        status = nil
        streamKey = nil
        hlsPlaybackURL = nil
        isTest = nil
    }


    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decode(Int.self, forKey: .id)
        storeId = try? container.decode(Int.self, forKey: .storeId)
        productId = try? container.decode(Int.self, forKey: .productId)
        filename = try? container.decode(String.self, forKey: .filename)
        name = try? container.decode(String.self, forKey: .name)
        status = try? container.decode(String.self, forKey: .status)
        streamKey = try? container.decode(String.self, forKey: .streamKey)
        hlsPlaybackURL = try? container.decode(URL.self, forKey: .hlsPlaybackURL)
        isTest = try? container.decode(Bool.self, forKey: .isTest)
    }
}
