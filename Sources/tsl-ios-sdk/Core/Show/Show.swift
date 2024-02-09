//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

public class Show {
    
    public static let shared = Show()

    private var showInstance = ShowData()
   
    public init() {
        
    }
    // MARK: - Public Methods
    /// Get the details of the show.
    public func getDetails(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        ShowProvider().fetchShow(showId: showId) { result in
            switch result {
            case .success(let showData):
                self.showInstance = showData
                // Set the details and invoke the completion with success.
                completion(.success(showData))
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                completion(.failure(error))
            }
        }
    }
    
    public func getStatus(showId: String, completion: @escaping (Result<EventData, Error>) -> Void) {
        ShowProvider().fetchCurrentEvent(showId: showId) { result in
            switch result {
            case .success(let apiResponse):
                // Set the details and invoke the completion with success.
                completion(.success(apiResponse))
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                completion(.failure(error))
            }
        }
    }
    
    public func getClosedCaptions(eventId: Int? = nil, showId: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        var eventInstance: Event?
        if let _ = showId {
            eventInstance = showInstance.currentEvent
        } else if let eventId = eventId {
            if let events = showInstance.events?.filter({ obj in
                obj.id == eventId
            }) {
                if let event = events.first {
                    eventInstance = event
                }
            }
        }
        if let fileName = eventInstance?.streamKey, eventInstance?.isTest == false {
            let captionUrl = APIEndpoint.getClosedCaptions(fileName: fileName)
            let fileNameURL = captionUrl.baseURL + captionUrl.path
            completion(.success(fileNameURL))
        } else {
            completion(.failure(APIClientError.invalidData))
        }
    }

        
}
