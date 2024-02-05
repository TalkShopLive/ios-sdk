//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-24.
//

import Foundation

protocol ChatProviderData {
    func createMessagingToken(completion: @escaping (String) -> Void)
    func initializePubNub(with token:String?)
    // Add other functions as needed
}


