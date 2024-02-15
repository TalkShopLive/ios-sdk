//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

public class Networking {
    
    // MARK: - Messaging Token
    
    /// Requests a messaging token for communication.
    /// - Parameter completion: A closure to handle the result of the operation.
    public static func createMessagingToken(completion: @escaping (Result<MessagingTokenResponse, Error>) -> Void) {
        // Create a MessagingTokenRequest with specific parameters.
        let messagingTokenRequest = MessagingTokenRequest(
            mode: "guest",
            user: MessagingTokenRequest.User(prefix: "walmart")
        )
        
        // Make a request using APIHandler and handle the result.
        APIHandler().request(endpoint: APIEndpoint.messagingToken, method: .post, body: messagingTokenRequest, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Shows
    
    /// Fetches show data based on the provided show ID.
    /// - Parameters:
    ///   - showId: The ID of the show to retrieve.
    ///   - completion: A closure to handle the result of the operation.
    public static func getShows(showId: String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        // Make a request to get show data using APIHandler and handle the result.
        APIHandler().request(endpoint: APIEndpoint.getShows(showId: showId), method: .get, body: nil, responseType: GetShowsResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse.product))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Get Current Event
    
    /// Fetches data for the current event based on the provided show ID.
    /// - Parameters:
    ///   - showId: The ID of the show to retrieve the current event for.
    ///   - completion: A closure to handle the result of the operation.
    public static func getCurrentEvent(showId: String, completion: @escaping (Result<EventData, Error>) -> Void) {
        // Make a request to get current event data using APIHandler and handle the result.
        APIHandler().request(endpoint: APIEndpoint.getCurrentEvent(showId: showId), method: .get, body: nil, responseType: EventData.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Register
    
    /// Registers the client using a provided client key.
    /// - Parameters:
    ///   - clientKey: The client key for registration.
    ///   - completion: A closure to handle the result of the registration operation.
    public static func register(clientKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Make a registration request using APIHandler and handle the result.
        APIHandler().requestToRegister(endpoint: APIEndpoint.register(clientKey: clientKey), method: .get, body: nil, responseType: RegisteredClientData.self) { result in
            switch result {
            case .success(let apiResponse):
                // Check if registration status is "ok" and set SDK initialization state.
                if apiResponse.status == "ok" {
                    print("SDK Initialized")
                    Config.shared.setInitialized(true)
                    completion(.success(()))
                } else {
                    // Handle case where SDK is not initialized due to an invalid key.
                    print("SDK is not initialized: Invalid Key")
                    completion(.failure(APIClientError.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Refresh Token
    
    /// Requests a refreshed messaging token.
    /// - Parameter completion: A closure to handle the result of the token refresh operation.
    public static func refreshToken(completion: @escaping (Result<MessagingTokenResponse, Error>) -> Void) {
        // Create a RefreshTokenRequest with specific parameters.
        let refreshTokenRequest = RefreshTokenRequest(
            mode: "guest",
            user: RefreshTokenRequest.User(prefix: "walmart"),
            refresh: true
        )
        
        // Make a request to refresh the messaging token using APIHandler and handle the result.
        APIHandler().request(endpoint: APIEndpoint.messagingToken, method: .post, body: refreshTokenRequest, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
