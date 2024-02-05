//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-26.
//

import Foundation

public extension TalkShopLive {
    func getShows(showId:String, completion: @escaping (Result<ShowData, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let showProvider = Show()
            showProvider.getDetails(showId: showId) { result in
                completion(result)
            }
        }
    }
    
}
