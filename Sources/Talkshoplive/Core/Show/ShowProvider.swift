//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

public class ShowProvider {
    
    public init() {
        
    }
    
    // MARK: - Private Methods

    /// Fetch show details from the network.
    /// - Parameter completion: A closure to be executed once the fetching is complete.
    internal func fetchShow(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        Networking.getShows(showId: showId, completion: { result in
            completion(result)
        })
    }
    
    internal func fetchCurrentEvent(showKey: String, completion: @escaping (Result<EventData, Error>) -> Void) {
        Networking.getCurrentEvent(showKey: showKey, completion: { result in
            completion(result)
        })
    }
}
