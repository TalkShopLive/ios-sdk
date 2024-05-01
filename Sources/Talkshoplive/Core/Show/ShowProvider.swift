//
//  ShowProvider.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

// MARK: - ShowProvider Class

// Show class responsible for managing show-related functionality
public class ShowProvider {
    
    // MARK: - Initializer
    public init() {
        
    }
    
    // MARK: - Private Methods

    /// Fetch show details from the network.
    /// - Parameters:
    ///   - showKey: The key of the show to fetch.
    ///   - completion: A closure to be executed once the fetching is complete.
    internal func fetchShow(
        showKey: String,
        completion: @escaping (Result<ShowData, APIClientError>) -> Void)
    {
        // Call the network function to fetch show details
        Networking.getShows(showKey: showKey, completion: { result in
            completion(result)
        })
    }
    
    /// Fetch the current event details from the network.
    /// - Parameters:
    ///   - showKey: The key of the show to fetch the current event for.
    ///   - completion: A closure to be executed once the fetching is complete.
    internal func fetchCurrentEvent(
        showKey: String,
        completion: @escaping (Result<EventData, APIClientError>) -> Void)
    {
        // Call the network function to fetch current event details
        Networking.getCurrentEvent(showKey: showKey, completion: { result in
            completion(result)
        })
    }
    
    /// Increment the view count for a specific event.
    /// - Parameters:
    ///   - eventId: The ID of the event for which to increment the view count.
    ///   - completion: A closure to be executed once the view count is incremented.
    internal func incrementView(
        eventId:Int,
        _ completion: ((Bool, APIClientError?) -> Void)? = nil)
    {
        // Call the network function to increment the view count
        Networking.getIncrementView(eventId: eventId) { status,error  in
            completion?(status,error)
        }
    }
}
