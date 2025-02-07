//
//  Collect.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

/// `Collect` is responsible for sending analytics events related to user interactions and system processes.
public class Collect {
    private let show: ShowData?  // Holds data related to the current show/event.
    private let userId: String?  // The ID of the user performing the action.

    /// Initializes the `Collect` instance with a show and an optional user ID.
    /// - Parameters:
    ///   - show: The `ShowData` object representing the current event.
    ///   - userId: An optional `String` representing the user ID.
    public init(show: ShowData, userId: String? = nil) {
        self.show = show
        self.userId = userId
    }

    /// Sends an analytics event to the server.
    ///
    /// - Parameters:
    ///   - actionName: The specific action being tracked (e.g., `SELECT_VIEW_CHAT`, `UPDATE_USER`).
    ///   - completion: An optional completion handler returning a success flag and an error if applicable.
    public func collect(
        actionName: CollectorRequest.CollectorActionType,
        completion: ((Bool, APIClientError?) -> Void)? = nil
    ) {
        let sdkVersion = "2.0.1" // Define the current SDK version.

        // Check if "Do Not Track" (DNT) mode is enabled.
        if Config.shared.isDntMode() == false {
            // If DNT mode is off, proceed with collecting analytics.

            Networking.collect(
                userId: userId ?? "NOT SET", // Use the user ID if available, otherwise default to "NOT SET".
                category: actionName.associatedCategory, // Determine the category based on the action type.
                version: sdkVersion, // Pass the SDK version.
                action: actionName, // Specify the action being performed.
                eventId: show?.eventId ?? nil, // Use the event ID if available.
                showKey: show?.showKey ?? "NOT SET", // Use the show key if available, otherwise default.
                storeId: show?.currentEvent?.storeId ?? nil, // Extract the store ID from the event if available.
                videoStatus: show?.status ?? "NOT SET", // Provide the current video status.
                videoTime: show?.duration ?? nil, // Capture the total event duration.
                screenResolution: getScreenResolution() // Get the current screen resolution.
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
