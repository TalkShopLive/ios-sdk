//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

public class Networking {
    
    public static func createMessagingToken(completion: @escaping (Result<MessagingTokenResponse, Error>) -> Void) {
        let messagingTokenRequest = MessagingTokenRequest(
            mode: "guest",
            user: MessagingTokenRequest.User(prefix: "walmart")
        )
        
        APIHandler().request(endpoint: APIEndpoint.messagingToken, method: .post, body:messagingTokenRequest, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
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
    
    public static func register(clientKey:String, completion: @escaping (Result<Void, Error>) -> Void) {
        APIHandler().requestToRegister(endpoint: APIEndpoint.register(clientKey: clientKey), method: .get, body:nil, responseType:RegisteredClientData.self) { result in
            switch result {
            case .success(let apiResponse):
                if apiResponse.status == "ok" {
                    print("SDK Initialized")
                    Config.shared.setInitialized(true)
                    completion(.success(()))
                } else {
                    print("SDK is not initialized : Invalid Key")
                    completion(.failure(APIClientError.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}

