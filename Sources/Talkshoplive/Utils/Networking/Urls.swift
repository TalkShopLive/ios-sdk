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
    case getCurrentEvent(showKey:String)
    case getClosedCaptions(fileName:String)
    case register
    case getGuestUserToken
    case getFederatedUserToken
    
    var baseURL: String {
        do {
            switch self {
            case .messagingToken, .getShows, .getCurrentEvent,.register,.getGuestUserToken,.getFederatedUserToken:
                return try Config.loadAPIConfig().BASE_URL
            case .getClosedCaptions:
                return try Config.loadAPIConfig().ASSETS_URL
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
        case .getCurrentEvent(showKey: let showKey):
            return "/api/shows/\(showKey)/streams/current"
        case .getClosedCaptions(fileName: let fileName):
            return "/events/\(fileName)_transcoded.transcript.vtt"
        case .register:
            return "/api2/v1/sdk"
        case .getGuestUserToken:
            return "/api2/v1/sdk/chat/guest_token"
        case .getFederatedUserToken:
            return "/api2/v1/sdk/chat/federated_user_token"
        }
    }
}
