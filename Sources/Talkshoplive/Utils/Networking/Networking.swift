//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

public class Networking {
    
    public static func createMessagingToken(jwtToken: String,isGuest:Bool, completion: @escaping (Result<MessagingTokenResponse, Error>) -> Void) {
    
        let endpoint = isGuest ? APIEndpoint.getGuestUserToken : APIEndpoint.getFederatedUserToken
        APIHandler().requestToken(jwtToken: jwtToken, endpoint: endpoint, method: .post, body: nil, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public static func getShows(showKey:String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getShows(showKey: showKey), method: .get, body:nil, responseType:GetShowsResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse.product))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public static func getCurrentEvent(showKey:String, completion: @escaping (Result<EventData, Error>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getCurrentEvent(showKey: showKey), method: .get, body:nil, responseType:EventData.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public static func register(clientKey:String, completion: @escaping (Result<Void, Error>) -> Void) {
        APIHandler().requestToRegister(clientKey:clientKey,endpoint: APIEndpoint.register, method: .get, body:nil, responseType:RegisteredClientData.self) { result in
            switch result {
            case .success(let apiResponse):
                if apiResponse.validKey == true {
                    print("SDK Initialized")
                    Config.shared.setInitialized(true)
                    completion(.success(()))
                } else {
                    print("SDK is not initialized : Invalid Authentication")
                    completion(.failure(APIClientError.authenticationInvalid))
                }
            case .failure(_):
                print("SDK is not initialized : Invalid Authentication")
                completion(.failure(APIClientError.authenticationInvalid))
            }
        }
    }
    
}

