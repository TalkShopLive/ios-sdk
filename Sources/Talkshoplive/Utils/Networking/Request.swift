//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

//MARK: - Collector Request

struct CollectorRequest: Codable {
    let timestampUtc: Int?
    let userId: String? // Assuming userId is of type String
    let category: CollectorCategory?
    let version: String?
    let action: CollectorActionType?
    let application: String?
    let meta: Meta?
    let utm: UTM?
    
    enum CollectorCategory: String, Codable {
        case interaction = "INTERACTION"
        case process = "PROCESS"
    }
    
    enum CollectorActionType: String, Codable {
        case sdkInitialized = "SDK_INITIALIZED"
        case selectViewShowDetails = "SELECT_SHOW_METADATA"
        case selectViewChat = "SELECT_VIEW_CHAT"
        case updateUser = "UPDATE_USER"
        case incrementViewCount = "INCREMENT_VIEW_COUNT"
    }

    enum CodingKeys: String, CodingKey {
        case timestampUtc = "timestamp_utc"
        case userId = "user_id"
        case category
        case version
        case action
        case application
        case meta
        case utm
    }
}

struct Meta: Codable {
    let external: Bool?
    let eventId: Int?
    let streamingContentKey: String?
    let storeId: Int?
    let videoStatus: String?
    let videoTime: Int?

    enum CodingKeys: String, CodingKey {
        case external
        case eventId = "event_id"
        case streamingContentKey = "streaming_content_key"
        case storeId = "store_id"
        case videoStatus = "video_status"
        case videoTime = "total_event_duration"
    }
}

struct UTM: Codable {
    let source: String?
    let campaign: String?
    let medium: String?
    let term: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source
        case campaign
        case medium
        case term
        case content
    }
}

