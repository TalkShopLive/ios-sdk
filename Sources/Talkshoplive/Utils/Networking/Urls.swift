//
// Urls.swift
//
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

//MARK: - APIEndpoint

/// Enum defining various API endpoints used in the application.
public enum APIEndpoint {
    case messagingToken
    case getShows(showKey: String)
    case getCurrentEvent(showKey: String)
    case getClosedCaptions(fileName: String)
    case getProducts(productIds: [Int])
    case register
    case getGuestUserToken
    case getFederatedUserToken
    case getHlsUrl(fileName: String)
    case deleteMessage(eventId: String,timetoken: String)
    case getCollector
    case getIncrementViewCount(eventId: Int)
    case getUserMetadata(uuid: String)
    case unlikeComment(eventId:String,messageTimeToken:String, actionTimeToken:String)
    
    /// Base URL for the API endpoint.
    var baseURL: String {
        do {
            switch self {
            case .messagingToken, .getShows, .getCurrentEvent,.register,.getGuestUserToken,.getFederatedUserToken,.deleteMessage,.getUserMetadata,.getProducts,.unlikeComment:
                return try Config.loadAPIConfig().BASE_URL
            case .getClosedCaptions,.getHlsUrl:
                return try Config.loadAPIConfig().ASSETS_URL
            case .getCollector:
                return try Config.loadAPIConfig().COLLECTOR_BASE_URL
            case .getIncrementViewCount:
                return try Config.loadAPIConfig().EVENTS_BASE_URL
            }
        } catch {
            fatalError("Failed to load configuration: \(error)")
        }
    }
    
    /// Path for the API endpoint.
    var path: String {
        switch self {
        case .messagingToken:
            return "/api/messaging_tokens"
        case .getShows(let showKey):
            return "/api/v1/shows/\(showKey)?expand=channel,fundraiser,assets,show_products"
        case .getCurrentEvent(showKey: let showKey):
            return "/api/v1/shows/\(showKey)/status"
        case .getProducts(productIds: let productIds):
            let perPage = 50
            let order = "array_order"
            let idsQuery = productIds.map { "ids[]=\($0)" }.joined(separator: "&")
            return "/api/fetch_multiple_products?\(idsQuery)&per_page=\(perPage)&order_by=\(order)"
        case .getClosedCaptions(fileName: let fileName):
            return "/events/\(fileName)_transcoded.transcript.vtt"
        case .register:
            return "/api2/v1/sdk"
        case .getGuestUserToken:
            return "/api2/v1/sdk/chat/guest_token"
        case .getFederatedUserToken:
            return "/api2/v1/sdk/chat/federated_user_token"
        case .getHlsUrl(fileName: let fileName):
            return "/events/\(fileName)"
        case .deleteMessage(eventId: let eventId, timetoken: let timetoken):
            return "/api2/v1/sdk/chat/messages/\(eventId)/\(timetoken)"
        case .getCollector:
            return "/collect"
        case .getIncrementViewCount(eventId: let eventId):
            return "/event/\(eventId)/increment"
        case .getUserMetadata(uuid: let uuid):
            return "/api/messaging/senders/\(uuid)"
        case .unlikeComment(eventId: let eventId, messageTimeToken: let messageTimeToken, actionTimeToken: let actionTimeToken):
            return "/api2/v1/sdk/chat/messages/\(eventId)/\(messageTimeToken)/\(actionTimeToken)"
        }
    }
}
