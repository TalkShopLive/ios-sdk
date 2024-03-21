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
    public func getDetails(showKey: String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        ShowProvider().fetchShow(showKey: showKey) { result in
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
    
    public func getStatus(showKey: String, completion: @escaping (Result<EventData, Error>) -> Void) {
        ShowProvider().fetchCurrentEvent(showKey: showKey) { result in
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
}
