//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

public class Show: ShowProviderData {
   
    public init() {
        
    }
    // MARK: - Public Methods

    /// Get the details of the show.
    public func getDetails(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        self.fetchShow(showId: showId) { result in
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
    // MARK: - Private Methods

    /// Fetch show details from the network.
    /// - Parameter completion: A closure to be executed once the fetching is complete.
    internal func fetchShow(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        Networking.getShows(showId: showId, completion: { result in
            completion(result)
        })
    }
}
