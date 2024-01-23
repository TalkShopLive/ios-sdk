//
//  File.swift
//  
//
//  Created by TalkShopLive on 2024-01-23.
//

import Foundation

public struct Config: Codable {
    public let PUBLISH_KEY: String
    public let SUBSCRIBE_KEY: String
    public let USER_ID: String
}

public struct APIConfig: Codable {
    public let BASE_URL: String
}


