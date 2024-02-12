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
    case register(clientKey:String)
    
    var baseURL: String {
        do {
            switch self {
            case .messagingToken, .getShows, .getCurrentEvent:
                return try Config.loadAPIConfig().BASE_URL
            case .getClosedCaptions:
                return try Config.loadAPIConfig().ASSETS_URL
            case .register:
                return ""
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
            return "/events/\(fileName)_transcoded.transcript.vtt"
        case .register(clientKey: let clientKey):
            return "https://mocki.io/v1/00134a6d-0077-4559-bb8f-a86627b34ddb?key=\(clientKey)"
        }
    }
}
