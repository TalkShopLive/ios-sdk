//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

public class Collector {
    
    // MARK: - Singleton
    private let sdkVerion = "1.0.1-beta"
    
    public static let shared = Collector()
    
    // MARK: - Properties
    
    init() {
        
    }
    
    func collect(userId:String? = nil,
                         category:CollectorRequest.CollectorCategory? = nil,
                         action:CollectorRequest.CollectorActionType? = nil,
                         eventId:Int? = nil,
                         showKey:String? = nil,
                         storeId:Int? = nil,
                         videoStatus:String? = nil,
                         videoTime:Int? = nil,
                         screenResolution:String? = nil,
                         _ completion: ((Bool, APIClientError?) -> Void)? = nil) {
        if Config.shared.isDntMode() == false {
            Networking.collect(userId: userId, category: category, version: sdkVerion, action: action, eventId: eventId, showKey: showKey, storeId: storeId, videoStatus: videoStatus, videoTime: videoTime, screenResolution: screenResolution) { result, error in
                completion?(result, error)
            }
        }
    }
    
}
