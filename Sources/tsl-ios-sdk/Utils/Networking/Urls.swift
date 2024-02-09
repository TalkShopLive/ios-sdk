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
    case getClosedCaptions(fileName:String)
    
    var baseURL: String {
        do {
            switch self {
            case .messagingToken, .getShows, .getCurrentEvent:
                return try ConfigLoader.loadAPIConfig().BASE_URL
            case .getClosedCaptions:
                return try ConfigLoader.loadAPIConfig().EVENTS_BASE_URL
            }
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    var path: String {
        switch self {
        case .messagingToken:
            return "/api/messaging_tokens"
        case .getShows(let showId):
            return "/api/products/digital/streaming_content/\(showId)"
        case .getCurrentEvent(showId: let showId):
            return "/api/shows/\(showId)/streams/current"
        case .getClosedCaptions(fileName: let fileName):
            return "/events/\(fileName)_transcoded.vtt"
            
        }
    }
}
