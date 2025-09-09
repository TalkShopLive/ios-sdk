//
//  Assets.swift
//  Talkshoplive
//
//  Created by Talkshoplive on 2025-04-29.
//

public struct Asset: Codable {
    let type: AssetType?
    let id: Int?
    let url: String?
    let duration: Int?
    let totalViews: Int?
    let transcriptionUrl: String?
    let fileExtension: String?

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case url
        case duration
        case totalViews = "total_views"
        case transcriptionUrl = "transcription_url"
        case fileExtension = "file_extension"
    }
}

public enum AssetType: Codable, Equatable {
    case trailer
    case live
    case vod
    case thumbnail
    case unknown(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        switch rawValue {
        case "trailer": self = .trailer
        case "live": self = .live
        case "vod": self = .vod
        case "thumbnail": self = .thumbnail
        default: self = .unknown(rawValue)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .trailer: try container.encode("trailer")
        case .live: try container.encode("live")
        case .vod: try container.encode("vod")
        case .thumbnail: try container.encode("thumbnail")
        case .unknown(let value): try container.encode(value)
        }
    }
}


