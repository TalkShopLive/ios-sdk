//
//  EventData.swift
//
//
//  Created by TalkShoLive on 2024-01-30.
//

import Foundation

public struct EventResponse: Codable {
    public let data: EventData
}

public struct EventData: Codable {
    public var id: Int?
    public var status: String?
    public var hlsPlaybackUrl: String?
    public var hlsUrl: String?
    private var url: String?
    public var duration: Int?

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case status = "state"
        case url      // ← Used only inside init
        case duration
    }

    // MARK: - Initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        status = try? container.decodeIfPresent(String.self, forKey: .status)
        duration = try? container.decodeIfPresent(Int.self, forKey: .duration)

        let url = try? container.decodeIfPresent(String.self, forKey: .url)

        // Map URL to proper field based on status
        switch status?.lowercased() {
        case "live":
            hlsPlaybackUrl = url
            hlsUrl = nil
        case "vod":
            hlsUrl = url
            hlsPlaybackUrl = nil
        default:
            hlsUrl = nil
            hlsPlaybackUrl = nil
        }
    }

    // Default init if needed
    public init() {
        id = nil
        status = nil
        url = nil
        hlsPlaybackUrl = nil
        hlsUrl = nil
        duration = nil
    }
}
