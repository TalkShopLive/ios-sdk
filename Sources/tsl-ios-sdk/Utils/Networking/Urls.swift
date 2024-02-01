//
// APIEndpoint.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public enum APIEndpoint {
    case messagingToken
    case getShows(showId:String)
    case getCurrentEvent(showId:String)


    var path: String {
        switch self {
        case .messagingToken:
            return "/api/messaging_tokens"
        case .getShows(let showId):
            return "/api/products/digital/streaming_content/\(showId)"
        case .getCurrentEvent(showId: let showId):
            return "/api/shows/\(showId)/streams/current"
        }
    }
}
