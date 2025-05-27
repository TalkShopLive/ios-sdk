//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

// MARK: - Networking Class 

//Networking Class responsible for handling network requests and interactions.
class Networking {
    
    //MARK: Initialize SDK
    /// Registers the SDK with the provided client key.
    /// - Parameters:
    ///   - clientKey: The client key used for SDK registration.
    ///   - completion: A closure to be called upon completion of the registration process.
    static func register(
        clientKey: String,
        completion: @escaping (Result<Void, APIClientError>) -> Void)
    {
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

    
    // MARK: - Shows

    /// Retrieves shows associated with a given show key.
    /// - Parameters:
    ///   - showKey: The key associated with the show.
    ///   - completion: A closure to be called upon completion, containing a result with either the show data or an error.
    static func getShows(
        showKey: String,
        completion: @escaping (Result<ShowData, APIClientError>) -> Void)
    {
        APIHandler().request(endpoint: APIEndpoint.getShows(showKey: showKey), method: .get, body: nil, responseType: GetShowsResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                // Successfully retrieved shows data
                completion(.success(apiResponse.data))
            case .failure(_):
                // Error occurred due to invalid show key
                completion(.failure(APIClientError.SHOW_NOT_FOUND))
            }
        }
    }

    /// Retrieves details of the current event for a given show key.
    /// - Parameters:
    ///   - showKey: The key associated with the show.
    ///   - completion: A closure to be called upon completion, containing a result with either the event data or an error.
    static func getCurrentEvent(
        showKey: String,
        completion: @escaping (Result<EventData, APIClientError>) -> Void)
    {
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
    
    /// Retrieves details of products for the given product IDs.
    /// - Parameters:
    ///   - productIds: The IDs of the products to retrieve details for.
    ///   - completion: A closure to be called upon completion, containing a result with either the product data or an error.
    static func getProducts(
        productIds: [Int],
        completion: @escaping (Result<[ProductData], APIClientError>) -> Void)
    {
        // Make a request to the APIHandler to fetch product details using the provided product IDs
        APIHandler().request(endpoint: APIEndpoint.getProducts(productIds: productIds), method: .get, body: nil, responseType: GetProductsResponse.self) { result in
            // Handle the result of the API request
            switch result {
            case .success(let apiResponse):
                // If products are successfully retrieved, invoke the completion with the product data
                completion(.success(apiResponse.products))
            case .failure(_):
                // If an error occurs, invoke the completion with failure indicating products not found
                completion(.failure(APIClientError.EVENT_NOT_FOUND))
            }
        }
    }
    
    // Increment the view count for the specified event.
    /// - Parameters:
    ///   - eventId: The ID of the event for which the view count should be incremented.
    ///   - completion: A closure to be called upon completion, containing a boolean indicating whether the view count was incremented successfully and an error if applicable.
    static func getIncrementView(
        eventId: Int,
        _ completion: ((Bool, APIClientError?) -> Void)? = nil)
    {
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

    
    // MARK: - Chat

    /// Creates a messaging token based on the provided JWT token and user type (guest or federated).
    /// - Parameters:
    ///   - jwtToken: The JWT token used for authentication.
    ///   - isGuest: A boolean indicating whether the user is a guest or federated user.
    ///   - completion: A closure to be called upon completion, containing a result with either the messaging token response or an error.
    static func createMessagingToken(
        jwtToken: String,
        isGuest: Bool,
        completion: @escaping (Result<MessagingTokenResponse, APIClientError>) -> Void)
    {
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

    /// Deletes a message with the provided JWT token, event ID, and time token.
    /// - Parameters:
    ///   - jwtToken: The JWT token used for authentication.
    ///   - eventId: The ID of the event associated with the message.
    ///   - timeToken: The time token associated with the message.
    ///   - completion: A closure to be called upon completion, containing a result indicating whether the message was successfully deleted or an error.
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
    
    // Unlike a comment with the provided JWT token, event ID, messageTimetoken and actionTimeToken
    static func unlikeComment(jwtToken:String, eventId: String, messageTimetoken: String, actionTimeToken: String,_ completion: @escaping (Result<Bool, APIClientError>) -> Void?) {
        // Make a request to unlike the comment
        APIHandler().requestDelete(jwtToken: jwtToken, endpoint: APIEndpoint.unlikeComment(eventId: eventId, messageTimeToken: messageTimetoken, actionTimeToken: actionTimeToken), method: .delete, body: nil) { result in
            switch result {
            case .success(_):
                // Successfully unliked a comment
                completion(.success(true))
            case .failure(_):
                // Failed to unlike a comment
                completion(.failure(APIClientError.UNKNOWN_EXCEPTION))
            }
        }
    }

    
    // MARK: - Collector

    /// Collects analytics data with the specified parameters.
    /// - Parameters:
    ///   - userId: The ID of the user associated with the action (optional).
    ///   - category: The category of the action (optional).
    ///   - version: The version of the application (optional).
    ///   - action: The type of action being performed (optional).
    ///   - eventId: The ID of the event associated with the action (optional).
    ///   - showKey: The key of the streaming content (optional).
    ///   - storeId: The ID of the store associated with the action (optional).
    ///   - videoStatus: The status of the video being watched (optional).
    ///   - videoTime: The time of the video being watched (optional).
    ///   - screenResolution: The resolution of the screen (optional).
    ///   - completion: A closure to be called upon completion, containing a boolean indicating whether the analytics data was sent successfully and an error if applicable.
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
                        showTitle: String? = nil,
                        _ completion: ((Bool, APIClientError?) -> Void)? = nil) {
        let collectorConfig = Config.loadCollectorURLConfig()
        let pageUrl = collectorConfig.pageUrl + (showKey ?? "")
        
        // Prepare page metrics data
        let pageMetrics = PageMetrics(
            origin: collectorConfig.origin,
            host: collectorConfig.host,
            referrer: collectorConfig.referrer,
            pageUrl: pageUrl,
            pageUrlRaw: pageUrl,
            pageTitle: showTitle
        )
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
                                       aspect: Aspect(
                                        screenResolution: screenResolution ?? "NOT_SET"
                                       ),
                                       pageMetrics: pageMetrics)
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
    
    // MARK: - Users
    
    // Fetches user metadata from the server using the provided UUID.
    /// - Parameters:
    ///   - uuid: The UUID of the user whose metadata is to be fetched.
    ///   - completion: A closure to be called upon completion, containing a result indicating either the fetched user metadata or an error.
    static func getUserMetadata(
        uuid: String,
        _ completion: @escaping (Result<Sender, APIClientError>) -> Void)
    {
        // Make a request to the APIHandler to fetch user metadata.
        APIHandler().request(endpoint: APIEndpoint.getUserMetadata(uuid: uuid), method: .get, body: nil, responseType: UserMetaResponse.self) { result in
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

