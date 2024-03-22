//
//  Networking.swift
//
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

class Networking {
    
    //MARK: Initialize SDK
    static func register(clientKey: String, completion: @escaping (Result<Void, Error>) -> Void) {
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
    
    //MARK: Shows
    static func getShows(showKey: String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getShows(showKey: showKey), method: .get, body:nil, responseType:GetShowsResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse.product))
            case .failure(let error):
                completion(.failure(APIClientError.invalidShowKey))
            }
        }
    }
    
    static func getCurrentEvent(showKey: String, completion: @escaping (Result<EventData, Error>) -> Void) {
        APIHandler().request(endpoint: APIEndpoint.getCurrentEvent(showKey: showKey), method: .get, body:nil, responseType:EventData.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(APIClientError.invalidShowKey))
            }
        }
    }
    
    //MARK: Chat
    static func createMessagingToken(jwtToken: String,isGuest: Bool, completion: @escaping (Result<MessagingTokenResponse, Error>) -> Void) {
        let endpoint = isGuest ? APIEndpoint.getGuestUserToken : APIEndpoint.getFederatedUserToken
        APIHandler().requestToken(jwtToken: jwtToken, endpoint: endpoint, method: .post, body: nil, responseType: MessagingTokenResponse.self) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(apiResponse))
            case .failure(let error):
                completion(.failure(APIClientError.tokenRetrievalFailed))
            }
        }
    }
    
    static func deleteMessage(jwtToken: String, eventId: String, timeToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        APIHandler().requestDelete(jwtToken: jwtToken, endpoint: APIEndpoint.deleteMessage(eventId: eventId, timetoken: timeToken), method: .delete, body: nil) { result in
            switch result {
            case .success(let apiResponse):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(APIClientError.somethingWentWrong))
            }
        }
    }
    
    //MARK: Collector
    static func collect(userId:String? = nil, 
                        category:CollectorRequest.CollectorCategory? = nil,
                        version:String? = nil,
                        action:CollectorRequest.CollectorActionType? = nil,
                        eventId:Int? = nil,
                        showKey:String? = nil,
                        storeId:Int? = nil,
                        videoStatus:String? = nil,
                        videoTime:Int? = nil,
                        screenResolution:String? = nil,
                        _ completion: ((Bool, Error?) -> Void)? = nil) {
        // Creating an instance of CollectorRequest
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
        APIHandler().request(endpoint: APIEndpoint.getCollector, method: .post, body: payload, responseType: NoResponse.self) { result in
            let actionType = payload.action!.rawValue
            switch result {
            case .success(let apiResponse):
                Config.shared.isDebugMode() ? print("Collector-\(actionType) :: Analytics Succeeded") : ()
                completion?(true,nil)
            case .failure(let error):
                Config.shared.isDebugMode() ? print("Collector-\(actionType)::Analytics Failed with error: \(error)") : ()
                completion?(false,error)
            }
        }
    }
    
}

