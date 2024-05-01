//
//  Show.swift
//
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

// MARK: - Show Class

// Show class responsible for managing show-related functionality through ShowProvider
public class Show {
    
    // MARK: - Properties
    public static let shared = Show()// Singleton instance for Show class
    private var showInstance = ShowData()
    private var incrementedView = [String: Bool]()
   
    // MARK: - Initializer
    public init() {
        
    }
    // MARK: - Public Methods
    /// Get the details of the show.
    public func getDetails(
        showKey: String,
        completion: @escaping (Result<ShowData, APIClientError>) -> Void) 
    {
        // Fetch show details using the provider
        ShowProvider().fetchShow(showKey: showKey) { result in
            switch result {
            case .success(let showData):
                // Update the show instance with fetched data
                self.showInstance = showData
                // Set the details and invoke the completion with success.
                completion(.success(showData))
                
                //Analytics
                Collector.shared.collect(category: .interaction,
                                         action: .selectViewShowDetails,
                                         eventId: self.showInstance.eventId ?? nil,
                                         showKey: self.showInstance.showKey ?? nil,
                                         storeId: self.showInstance.currentEvent?.storeId ?? nil,
                                         videoStatus: self.showInstance.status,
                                         videoTime: self.showInstance.duration ?? nil)
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                completion(.failure(error))
            }
        }
    }
    
    /// Get the status of the show.
    public func getStatus(
        showKey: String,
        completion: @escaping (Result<EventData, APIClientError>) -> Void)
    {
        // Fetch current event status using the provider
        ShowProvider().fetchCurrentEvent(showKey: showKey) { result in
            switch result {
            case .success(let eventInstance):
                // Set the details and invoke the completion with success.
                completion(.success(eventInstance))
                if let incremented = self.incrementedView[showKey], !incremented,
                   let eventId = eventInstance.id,
                    eventInstance.streamInCloud == true,
                    eventInstance.status == "live"
                {
                    ShowProvider().incrementView(eventId: eventId) { status, error in
                        if status {
                            self.incrementedView[showKey] = true
                            Config.shared.isDebugMode() ? print("Incremented View!") : ()
                            //Analytics
                            Collector.shared.collect(category: .interaction,
                                                     action: .incrementViewCount,
                                                     eventId: eventInstance.id ?? nil,
                                                     showKey: showKey ,
                                                     storeId: eventInstance.storeId ?? nil,
                                                     videoStatus: eventInstance.status,
                                                     videoTime: eventInstance.duration ?? nil)
                        } else {
                            Config.shared.isDebugMode() ? print("Increment View Failed: \(error?.localizedDescription ?? "")") : ()
                        }
                    }
                }
            case .failure(let error):
                // Invoke the completion with failure if an error occurs.
                completion(.failure(error))
            }
        }
    }
}
