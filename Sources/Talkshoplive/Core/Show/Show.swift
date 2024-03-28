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
    private var incrementedView = [String: Bool]()
   
    public init() {
        
    }
    // MARK: - Public Methods
    /// Get the details of the show.
    public func getDetails(showKey: String, completion: @escaping (Result<ShowData, APIClientError>) -> Void) {
        
        ShowProvider().fetchShow(showKey: showKey) { result in
            switch result {
            case .success(let showData):
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
    
    public func getStatus(showKey: String, completion: @escaping (Result<EventData, APIClientError>) -> Void) {
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
