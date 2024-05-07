//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

class Networking {
    
    //MARK: Initialize SDK
    static func register(clientKey: String, completion: @escaping (Result<Void, APIClientError>) -> Void) {
        // Making a request to register the SDK with the provided client key
        APIHandler().requestToRegister(clientKey: clientKey, endpoint: APIEndpoint.register, method: .get, body: nil, responseType: RegisteredClientData.self) { result in
            switch result {
            case .success(let apiResponse):
                // If the client key is valid, SDK initialized successfully
                if apiResponse.validKey == true {
                    print("SDK Initialized")
                    // Set the SDK initialization status to true
                    Config.shared.setInitialized(true)
                    completion(.success(()))
                } else {
                    // If the client key is invalid, SDK initialization failed due to authentication error
                    print("SDK Initialization Failed: TSL.\(APIClientError.AUTHENTICATION_EXCEPTION.localizedDescription)")
                    completion(.failure(APIClientError.AUTHENTICATION_FAILED))
                }
            case .failure(_):
                // SDK initialization failed due to request failure or invalid response
                print("SDK Initialization Failed: TSL.\(APIClientError.AUTHENTICATION_EXCEPTION.localizedDescription)")
                completion(.failure(APIClientError.AUTHENTICATION_EXCEPTION))
            }
        }
    }

    
    //MARK: Shows

    // Retrieve shows associated with a given show key
    static func getShows(showKey: String, completion: @escaping (Result<ShowData, APIClientError>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getShows(showKey: showKey), method: .get, body: nil, responseType: GetShowsResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                // Successfully retrieved shows data
                completion(.success(apiResponse.product))
            case .failure(_):
                // Error occurred due to invalid show key
                completion(.failure(APIClientError.SHOW_NOT_FOUND))
            }
        }
    }

    // Retrieve details of the current event for a given show key
    static func getCurrentEvent(showKey: String, completion: @escaping (Result<EventData, APIClientError>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getCurrentEvent(showKey: showKey), method: .get, body: nil, responseType: EventData.self) { result in
            switch result {
            case .success(let apiResponse):
                // Successfully retrieved current event data
                completion(.success(apiResponse))
            case .failure(_):
                // Error occurred due to event not found
                completion(.failure(APIClientError.EVENT_NOT_FOUND))
            }
        }
    }

    
    //MARK: Chat

    // Create a messaging token based on the provided JWT token and user type (guest or federated)
    static func createMessagingToken(jwtToken: String, isGuest: Bool, completion: @escaping (Result<MessagingTokenResponse, APIClientError>) -> Void) {
        // Determine the endpoint based on whether the user is a guest or federated
        let endpoint = isGuest ? APIEndpoint.getGuestUserToken : APIEndpoint.getFederatedUserToken
        // Make a request to retrieve the messaging token
        APIHandler().requestToken(jwtToken: jwtToken, endpoint: endpoint, method: .post, body: nil, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                // Successfully retrieved messaging token
                completion(.success(apiResponse))
            case .failure(_):
                // Failed to retrieve messaging token
                completion(.failure(APIClientError.INVALID_USER_TOKEN))
            }
        }
    }

    // Delete a message with the provided JWT token, event ID, and time token
    static func deleteMessage(jwtToken: String, eventId: String, timeToken: String, completion: @escaping (Result<Bool, APIClientError>) -> Void) {
        // Make a request to delete the message
        APIHandler().requestDelete(jwtToken: jwtToken, endpoint: APIEndpoint.deleteMessage(eventId: eventId, timetoken: timeToken), method: .delete, body: nil) { result in
            switch result {
            case .success(_):
                // Successfully deleted the message
                completion(.success(true))
            case .failure(_):
                // Failed to delete the message
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
            }
        }
    }

    
    //MARK: Collector

    // Collect analytics data with the specified parameters
    static func collect(userId: String? = nil,
                        category: CollectorRequest.CollectorCategory? = nil,
                        version: String? = nil,
                        action: CollectorRequest.CollectorActionType? = nil,
                        eventId: Int? = nil,
                        showKey: String? = nil,
                        storeId: Int? = nil,
                        videoStatus: String? = nil,
                        videoTime: Int? = nil,
                        screenResolution: String? = nil,
                        _ completion: ((Bool, APIClientError?) -> Void)? = nil) {
        // Create an instance of CollectorRequest
        let payload = CollectorRequest(timestampUtc: Int(Date().milliseconds),
                                       userId: userId ?? "NOT_SET",
                                       category: category,
                                       version: version,
                                       action: action,
                                       application: "ios",
                                       meta: Meta(external: true,
                                                  eventId: eventId,
                                                  streamingContentKey: showKey ?? "NOT_SET",
                                                  storeId: storeId,
                                                  videoStatus: videoStatus ?? "NOT_SET",
                                                  videoTime: videoTime),
                                       utm: UTM(source: "NOT_SET",
                                                campaign: "NOT_SET",
                                                medium: "NOT_SET",
                                                term: "NOT_SET",
                                                content: "NOT_SET"),
                                       aspect: Aspect(screenResolution: screenResolution ?? "NOT_SET"))
        // Make a request to send analytics data to the server
        APIHandler().request(endpoint: APIEndpoint.getCollector, method: .post, body: payload, responseType: NoResponse.self) { result in
            let actionType = payload.action!.rawValue
            switch result {
            case .success(_):
                // Analytics data sent successfully
                Config.shared.isDebugMode() ? print("Collector-\(actionType) :: Analytics Succeeded") : ()
                completion?(true, nil)
            case .failure(let error):
                // Failed to send analytics data
                Config.shared.isDebugMode() ? print("Collector-\(actionType)::Analytics Failed with error: \(error)") : ()
                completion?(false, error)
            }
        }
    }

    // Increment the view count for the specified event
    static func getIncrementView(eventId: Int, _ completion: ((Bool, APIClientError?) -> Void)? = nil) {
        // Make a request to increment the view count
        APIHandler().request(endpoint: APIEndpoint.getIncrementViewCount(eventId: eventId), method: .post, body: nil, responseType: IncrementViewResponse.self) { result in
            switch result {
            case .success(_):
                // View count incremented successfully
                completion?(true, nil)
            case .failure(let error):
                // Failed to increment view count
                completion?(false, error)
            }
        }
    }
    
    //MARK: Users
    
    // Fetches user metadata from the server using the provided UUID.
    static func getUserMetadata(uuid: String, _ completion: @escaping (Result<Sender, APIClientError>) -> Void) {
        // Make a request to the APIHandler to fetch user metadata.
        APIHandler().request(endpoint: APIEndpoint.getUserMetadata(uuid: uuid), method: .get, body: nil, responseType: UserMeataResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                // User's metadata fetched successfully
                if let sender = apiResponse.sender {
                    completion(.success(sender))
                } else {
                    completion(.failure(APIClientError.NO_DATA))
                }
            case .failure(_):
                // Failed to get user metadata
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
            }
        }
    }

    
}

