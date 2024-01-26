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
        APIHandler().postRequest(endpoint: APIEndpoint.messagingToken, body:messagingTokenRequest, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse.token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}

