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
    public var duration: Int?
    public var hls_playback_url: String?
    public var hls_url: String?
    var isTest: Bool?
    public var ended_at : String?

    enum CodingKeys: String, CodingKey {
        case id
        case storeId = "store_id"
        case productId = "product_id"
        case filename
        case name
        case status
        case streamKey = "stream_key"
        case duration = "duration"
        case hls_playback_url
        case isTest = "is_test"
        case ended_at
        case hls_url
    }
    
    public init() {
        id = nil
        storeId = nil
        productId = nil
        filename = nil
        name = nil
        status = nil
        streamKey = nil
        duration = nil
        hls_playback_url = nil
        isTest = nil
        ended_at = nil
        hls_url = nil
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
        duration = try? container.decode(Int.self, forKey: .duration)
        hls_playback_url = try? container.decode(String.self, forKey: .hls_playback_url)
        isTest = try? container.decode(Bool.self, forKey: .isTest)
        ended_at = try? container.decode(String.self, forKey: .ended_at)
        
        if let fileName = filename {
            let url = APIEndpoint.getHlsUrl(fileName: fileName)
            hls_url = url.baseURL + url.path
        } else {
            hls_url = nil
        }
    }
}
