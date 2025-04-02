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
        case addToCartAffiliate = "ADD_TO_CART_AFFILIATE"
        case selectProduct = "SELECT_PRODUCT"
        case selectViewProductDetails = "SELECT_VIEW_PRODUCT_DETAILS"
        case expandProductDetails = "EXPAND_PRODUCT_DETAILS"
        case customizeProduct = "CUSTOMIZE_PRODUCT"
        case customizeProductQuantityIncrease = "CUSTOMIZE_PRODUCT_QUANTITY_INCREASE"
        case customizeProductQuantityDecrease = "CUSTOMIZE_PRODUCT_QUANTITY_DECREASE"
        case selectAddToCartPDPDetails = "SELECT_ADD_TO_CART_PDP_DETAILS"
        case selectAddToCartStreamView = "SELECT_ADD_TO_CART_STREAM_VIEW"
        case selectProductCart = "SELECT_PRODUCT_CART"
        
        
        /// Returns the associated category for each action.
        var associatedCategory: CollectorCategory {
            switch self {
            case .viewContent:
                return .pageView
            case .videoComplete, .videoTime, .videoView:
                return .process
            case .videoPause, .videoPlay, .addToCart, .addToCartAffiliate, .selectProduct, .selectViewProductDetails,
                    .expandProductDetails, .customizeProduct, .customizeProductQuantityIncrease,
                    .customizeProductQuantityDecrease, .selectAddToCartPDPDetails,
                    .selectAddToCartStreamView, .selectProductCart:
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
//MARK: - Aspect Object

/// A structure representing aspect parameters associated with a collector request.
struct Aspect: Codable {
    let screenResolution: String?

    // MARK: Coding Keys
    enum CodingKeys: String, CodingKey {
        case screenResolution = "screen_resolution"
    }
}
