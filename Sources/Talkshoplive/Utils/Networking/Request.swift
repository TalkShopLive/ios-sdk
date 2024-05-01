//
//  Request.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

//MARK: - Collector Request

/// A structure representing a collector request containing analytics data.
struct CollectorRequest: Codable {
    let timestampUtc: Int?
    let userId: String? // Assuming userId is of type String
    let category: CollectorCategory?
    let version: String?
    let action: CollectorActionType?
    let application: String?
    let meta: Meta?
    let utm: UTM?
    let aspect: Aspect?
    
    // MARK: CollectorCategory
    /// An enumeration representing the category of the collector request.
    enum CollectorCategory: String, Codable {
        case interaction = "INTERACTION"
        case process = "PROCESS"
    }
    
    // MARK: CollectorActionType
    /// An enumeration representing the action type of the collector request.
    enum CollectorActionType: String, Codable {
        case sdkInitialized = "SDK_INITIALIZED"
        case selectViewShowDetails = "SELECT_SHOW_METADATA"
        case selectViewChat = "SELECT_VIEW_CHAT"
        case updateUser = "UPDATE_USER"
        case incrementViewCount = "INCREMENT_VIEW_COUNT"
    }

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case timestampUtc = "timestamp_utc"
        case userId = "user_id"
        case category
        case version
        case action
        case application
        case meta
        case utm
        case aspect
    }
}

//MARK: - Meta Object

/// A structure representing additional metadata associated with a collector request.
struct Meta: Codable {
    let external: Bool?
    let eventId: Int?
    let streamingContentKey: String?
    let storeId: Int?
    let videoStatus: String?
    let videoTime: Int?

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case external
        case eventId = "event_id"
        case streamingContentKey = "streaming_content_key"
        case storeId = "store_id"
        case videoStatus = "video_status"
        case videoTime = "total_event_duration"
    }
}

//MARK: - UTM Object

/// A structure representing UTM parameters associated with a collector request.
struct UTM: Codable {
    let source: String?
    let campaign: String?
    let medium: String?
    let term: String?
    let content: String?

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case source
        case campaign
        case medium
        case term
        case content
    }
}

//MARK: - Aspect Object

/// A structure representing aspect parameters associated with a collector request.
struct Aspect: Codable {
    let screenResolution: String?

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case screenResolution = "screen_resolution"
    }
}
