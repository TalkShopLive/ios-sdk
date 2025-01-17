//
//  Collector.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

// MARK: - Collector Class

// Collector class responsible for managing analytics
public class Collector {
    
    // MARK: - Properties
    private let sdkVerion = "2.0.0" // SDK version used by the collector.
    public static let shared = Collector() // Singleton instance of the Collector.
 
    // MARK: Initializers
    init() {
        
    }
    
    // MARK: - Internal Methods
    
    /// Collects analytics data with the specified parameters.
    /// - Parameters:
    ///   - userId: The user identifier.
    ///   - category: The category of the collector request.
    ///   - action: The action type of the collector request.
    ///   - eventId: The event identifier.
    ///   - showKey: The key of the show associated with the event.
    ///   - storeId: The store identifier.
    ///   - videoStatus: The status of the video.
    ///   - videoTime: The time of the video.
    ///   - screenResolution: The resolution of the screen.
    ///   - completion: A closure to be executed when the collection is complete. It returns a boolean indicating success and an optional error.
    internal func collect(userId:String? = nil,
                          category:CollectorRequest.CollectorCategory? = nil,
                          action:CollectorRequest.CollectorActionType? = nil,
                          eventId:Int? = nil,
                          showKey:String? = nil,
                          storeId:Int? = nil,
                          videoStatus:String? = nil,
                          videoTime:Int? = nil,
                          screenResolution:String? = nil,
                          _ completion: ((Bool, APIClientError?) -> Void)? = nil)
    {
        // Check if Do Not Track mode is enabled
        if Config.shared.isDntMode() == false {
            // Call the networking layer to send the analytics data
            Networking.collect(
                userId: userId,
                category: category,
                version: sdkVerion,
                action: action,
                eventId: eventId,
                showKey: showKey,
                storeId: storeId,
                videoStatus: videoStatus,
                videoTime: videoTime,
                screenResolution: screenResolution)
            { result, error in
                // Execute the completion handler
                completion?(result, error)
            }
        }
    }
    
}
