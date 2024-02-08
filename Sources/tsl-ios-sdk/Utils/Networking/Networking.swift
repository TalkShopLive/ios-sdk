//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

public class Networking {
    
    public static func postMessagingToken(completion: @escaping (Result<String, Error>) -> Void) {
        let messagingTokenRequest = MessagingTokenRequest(
            name: "Guest User Walmart",
            id: "guest_user_123",
            guest_token: "oyrVT6p94Ep",
            refresh: true // or false
        )
        APIHandler().request(endpoint: APIEndpoint.messagingToken, method: .post, body:messagingTokenRequest, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse.token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public static func getShows(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getShows(showId: showId), method: .get, body:nil, responseType:GetShowsResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse.product))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public static func getCurrentEvent(showId:String, completion: @escaping (Result<EventData, Error>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getCurrentEvent(showId: showId), method: .get, body:nil, responseType:EventData.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

