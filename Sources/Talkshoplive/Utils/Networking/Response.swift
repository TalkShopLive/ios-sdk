//
// APIResponseModel.swift
//  
//
//  Created by TalkShopLive on 2024-01-19.
//

import Foundation

public struct MessagingTokenResponse: Codable {
    let user_id: String
    let token: String
}

public struct GetShowsResponse: Codable {
    let product : ShowData
}

