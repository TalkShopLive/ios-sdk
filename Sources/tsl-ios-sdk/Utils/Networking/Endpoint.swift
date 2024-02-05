//
// APIEndpoint.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public enum APIEndpoint {
    case messagingToken
    case getShows(productKey:String)

    var path: String {
        switch self {
        case .messagingToken:
            return "/api/messaging_tokens"
        case .getShows(let productKey):
            return "/api/products/digital/streaming_content/\(productKey)"
        }
    }
}
