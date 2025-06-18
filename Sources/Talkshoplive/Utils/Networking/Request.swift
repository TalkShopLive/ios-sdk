//
//  Request.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

//MARK: - Collector Request

/// A structure representing a collector request containing analytics data.
public struct CollectorRequest: Codable {
    let timestampUtc: Int?
    let userId: String? // Assuming userId is of type String
    let category: CollectorCategory?
    let version: String?
    let action: CollectorActionType?
    let application: String?
    let meta: Meta?
    let aspect: Aspect?
    let pageMetrics: PageMetrics?
    
    // MARK: CollectorCategory
    /// An enumeration representing the category of the collector request.
    enum CollectorCategory: String, Codable {
        case interaction = "INTERACTION"
        case process = "PROCESS"
        case pageView = "PAGE_VIEW"
    }
    
    // MARK: CollectorActionType
    /// An enumeration representing the action type of the collector request.
    public enum CollectorActionType: String, Codable {
        case videoComplete = "VIDEO_COMPLETE"
        case videoTime = "VIDEO_TIME"
        case videoPause = "VIDEO_PAUSE"
        case videoPlay = "VIDEO_PLAY"
        case videoView = "VIDEO_VIEW"
        case viewContent = "VIEW_CONTENT"
        case addToCart = "ADD_TO_CART"
        case selectProduct = "SELECT_PRODUCT"
        case customizeProductQuantityIncrease = "CUSTOMIZE_PRODUCT_QUANTITY_INCREASE"
        case customizeProductQuantityDecrease = "CUSTOMIZE_PRODUCT_QUANTITY_DECREASE"
        
        
        /// Returns the associated category for each action.
        var associatedCategory: CollectorCategory {
            switch self {
            case .viewContent:
                return .pageView
            case .videoComplete, .videoTime, .videoView:
                return .process
            case .videoPause, .videoPlay, .addToCart,.selectProduct,
                    .customizeProductQuantityIncrease,.customizeProductQuantityDecrease:
                return .interaction
            }
        }
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
        case aspect
        case pageMetrics = "page_metrics"  
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
    let showId: Int?

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case external
        case eventId = "event_id"
        case streamingContentKey = "streaming_content_key"
        case storeId = "store_id"
        case videoStatus = "video_status"
        case videoTime = "total_event_duration"
        case showId = "show_id"
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

//MARK: - Aspect Object
/// A structure representing page metrics information.
struct PageMetrics: Codable {
    let origin: String?
    let host: String?
    let referrer: String?
    let pageUrl: String?
    let pageUrlRaw: String?
    let pageTitle: String?

    enum CodingKeys: String, CodingKey {
        case origin
        case host
        case referrer
        case pageUrl = "page_url"
        case pageUrlRaw = "page_url_raw"
        case pageTitle = "page_title"
    }
}

