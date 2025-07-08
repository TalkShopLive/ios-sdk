//
//  Collect.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

/// `Collect` is responsible for sending analytics events related to user interactions and system processes.
public class Collect {
    private let event: EventData  // Holds data related to the current show/event.
    private let userId: String  // The ID of the user performing the action.

    /// Initializes the `Collect` instance with a show and an optional user ID.
    /// - Parameters:
    ///   - show: The `ShowData` object representing the current event.
    ///   - userId: A `String` representing the unique user identifier associated with the action.
    public init(event: EventData, userId: String) {
        self.event = event
        self.userId = userId
    }

    /// Sends an analytics event to the server.
    ///
    /// - Parameters:
    ///   - actionName: The specific action being tracked (e.g., `SELECT_VIEW_CHAT`, `UPDATE_USER`).
    ///   - completion: An optional completion handler returning a success flag and an error if applicable.
    public func collect(
        actionName: CollectorRequest.CollectorActionType,
        videoTime:Int,
        completion: ((Bool, APIClientError?) -> Void)? = nil
    ) {
        let sdkVersion = "3.0.3" // Define the current SDK version.

        // Check if "Do Not Track" (DNT) mode is enabled.
        if Config.shared.isDntMode() == false {
            // If DNT mode is off, proceed with collecting analytics.
            let showInstance = Show.shared.showData
            Networking.collect(
                userId: userId,
                category: actionName.associatedCategory, // Determine the category based on the action type.
                version: sdkVersion, // Pass the SDK version.
                action: actionName, // Specify the action being performed.
                eventId: showInstance.eventId ?? nil, // Use the event ID if available.
                showKey: showInstance.showKey ?? "NOT SET", // Use the show key if available, otherwise default.
                storeId: showInstance.channel?.id ?? nil, // Extract the store ID from the event if available.
                videoStatus: event.status ?? "NOT SET", // Provide the current video status.
                videoTime: videoTime, // Capture the event current duration.
                screenResolution: getScreenResolution(), // Get the current screen resolution.
                showTitle: showInstance.name ?? "NOT SET",
                showId: showInstance.id ?? nil
            ) { result, error in
                // Execute the completion handler with the result.
                completion?(result, error)
            }
        } else {
            // If DNT mode is enabled, do not collect analytics, return failure.
            completion?(false, nil)
        }
    }
}
