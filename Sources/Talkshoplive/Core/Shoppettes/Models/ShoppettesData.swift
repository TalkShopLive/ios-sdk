//
//  ShoppettesData.swift
//  Talkshoplive
//
//  Created by Talkshoplive on 2025-09-22.
//

import Foundation

// MARK: - ShoppetteData
public struct ShoppetteData: Codable {
    public var id: Int?
    public var uuid: String?
    public var name: String?
    public var description: String?
    public var status: String?
    public var publishedAt: String?
    public var createdAt: String?
    public var updatedAt: String?
    public var tags: String?
    public var productIds: [Int]?
    public var videoUrl: String?
    public var thumbnailUrl: String?
    public var videoStatus: String?
    public var shoppableUntil: String?

    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id, uuid, name, description, status, tags
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case productIds = "product_ids"
        case videoUrl = "video_url"
        case thumbnailUrl = "thumbnail_url"
        case videoStatus = "video_status"
        case shoppableUntil = "shoppable_until"
    }

    // MARK: - Initializer
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try? container.decodeIfPresent(Int.self, forKey: .id)
        uuid = try? container.decodeIfPresent(String.self, forKey: .uuid)
        name = try? container.decodeIfPresent(String.self, forKey: .name)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        status = try? container.decodeIfPresent(String.self, forKey: .status)
        publishedAt = try? container.decodeIfPresent(String.self, forKey: .publishedAt)
        createdAt = try? container.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try? container.decodeIfPresent(String.self, forKey: .updatedAt)
        tags = try? container.decodeIfPresent(String.self, forKey: .tags)
        productIds = try? container.decodeIfPresent([Int].self, forKey: .productIds)
        videoUrl = try? container.decodeIfPresent(String.self, forKey: .videoUrl)
        thumbnailUrl = try? container.decodeIfPresent(String.self, forKey: .thumbnailUrl)
        videoStatus = try? container.decodeIfPresent(String.self, forKey: .videoStatus)
        shoppableUntil = try? container.decodeIfPresent(String.self, forKey: .shoppableUntil)
    }

    // Default init if needed
    public init() {
        id = nil
        uuid = nil
        name = nil
        description = nil
        status = nil
        publishedAt = nil
        createdAt = nil
        updatedAt = nil
        tags = nil
        productIds = nil
        videoUrl = nil
        thumbnailUrl = nil
        videoStatus = nil
        shoppableUntil = nil
    }
}

// MARK: - MetaData
public struct ShoppettesMetaData: Codable {
    public var currentPage: Int?
    public var nextPage: Int?
    public var prevPage: Int?
    public var totalPages: Int?
    public var totalCount: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case nextPage = "next_page"
        case prevPage = "prev_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
    }
}
