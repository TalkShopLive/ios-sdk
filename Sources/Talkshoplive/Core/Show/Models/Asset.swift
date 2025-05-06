//
//  Assets.swift
//  Talkshoplive
//
//  Created by Talkshoplive on 2025-04-29.
//

public struct Asset: Codable {
    let type: AssetType?
    let id: StringOrInt
    let url: String?
    let duration: Int?
    let orientation: String?
    let thumbnailImageUrl: String?
    let state: String?
    let disconnectedAt: String?
    let totalViews: Int?

    public enum CodingKeys: String, CodingKey {
        case type
        case id
        case url
        case duration
        case orientation
        case thumbnailImageUrl = "thumbnail_image_url"
        case state
        case disconnectedAt = "disconnected_at"
        case totalViews = "total_views"
    }
}

public enum AssetType: String, Codable {
    case trailer
    case live
    case vod
}

// To handle id being String in some cases and Int in others
public enum StringOrInt: Codable {
    case string(String)
    case int(Int)
    
    public var stringValue: String {
        switch self {
        case .int(let value):
            return String(value)
        case .string(let value):
            return value
        }
    }
    
    public var intValue: Int? {
        switch self {
        case .int(let value):
            return value
        case .string(let value):
            return Int(value)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let strVal = try? container.decode(String.self) {
            self = .string(strVal)
        } else {
            throw DecodingError.typeMismatch(StringOrInt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or Int"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let val):
            try container.encode(val)
        case .string(let val):
            try container.encode(val)
        }
    }
}

